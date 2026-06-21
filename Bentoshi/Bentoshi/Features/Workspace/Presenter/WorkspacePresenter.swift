//
//  WorkspacePresenter.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

import SwiftUI
import SwiftData

enum ArtefactPayload {
    case archive(url: URL, name: String)
    case link(url: URL, title: String)
    case text(title: String, content: String)
}

@Observable
final class WorkspacePresenter {
    private let interactor: WorkspaceInteractor
    
    var searchedItems: [SearchIndex] = []
    var searchText: String = ""
    var isSearching = false
    var isSearchBarExpanded = false

    private var searchTask: Task<Void, Never>?
    
    var allWorkspaces: [Workspace] = []
    
    
    init(interactor: WorkspaceInteractor) {
        self.interactor = interactor
    }
    

    func deleteWorkspace(_ workspace: Workspace) async {
        do {
            try await interactor.deleteWorkspace(id: workspace.id)
        } catch {
            print("Erro ao deletar workspace")
        }
    }
    
    func updateWorkspace(_ workspace: Workspace, newName: String, newCoverColor: WorkspaceColor) async {
        do {
            workspace.name = newName
            workspace.coverColor = newCoverColor
            
            try await interactor.updateWorkspace(workspace)
        } catch {
            print("Erro ao atualizar workspace")
        }
    }
    
    func addArtefact(to workspace: Workspace, payload: ArtefactPayload) async {
        switch payload {

        case .archive(let url, let name):
            await addArchiveArtefact(
                to: workspace,
                archiveUrl: url,
                withName: name
            )

        case .link(let url, let name):
            // await addLinkArtefact(to: workspace, url: url, title: title)
            break // apagar essa linha depois que implementar

        case .text(let name, let content):
            // await addTextArtefact(to: workspace, title: title, content: content)
            break // apagar essa linha depois que implementar
        }
    }
    
    func addArchiveArtefact(to workspace: Workspace, archiveUrl: URL, withName name: String) async {
        do {
            let bookmark = try archiveUrl.bookmarkData(
                options: [.withSecurityScope],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            
            let artefact = Artefact(name: name, type: .archive, content: archiveUrl.lastPathComponent, workspaceId: workspace.id, width: 100, height: 100, positionX: 0, positionY: 0, bookmark: bookmark)
            
            workspace.artefacts.append(artefact)
            
            try await interactor.updateWorkspace(workspace)
        } catch {
            print(error)
        }
    }
    
    func open(_ artefact: Artefact) {
        switch artefact.type {
        case .archive:
            openArchive(artefact)

        case .link:
            // openLink(artefact)
            break // apagar essa linha depois que implementar

        case .text:
            // openTextEditor(artefact)
            break // apagar essa linha depois que implementar
        }
    }
    
    func openArchive(_ artefact: Artefact) {
        
        guard let url = artefact.archiveUrl else { return }
        
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        NSWorkspace.shared.open(url)
    }
    
    func deleteArtefact(_ artefact: Artefact, from workspace: Workspace) async {
        do {
            try await interactor.deleteArtefact(id: artefact.id, from: workspace)
        } catch {
            print("Erro ao deletar artefato: \(error)")
        }
    }
    
    func updateArchiveArtefact(_ artefact: Artefact, newURL: URL, newName: String) async {
        do {
            artefact.name = newName
            artefact.bookmark = try newURL.bookmarkData(
                options: [.withSecurityScope],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )

            try await interactor.updateArtefact(artefact)

        } catch {
            print("Erro ao atualizar arquivo: \(error)")
        }
    }
    
    func revealArchiveInFinder(_ artefact: Artefact) {
        guard let url = artefact.archiveUrl else { return }

        let accessing = url.startAccessingSecurityScopedResource()

        defer {
            if accessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    func onSearchTextChangedOn(_ workspace: Workspace) {
        searchTask?.cancel()

        let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedText.isEmpty else {
            searchedItems = []
            isSearching = false
            return
        }

        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(400))

            if Task.isCancelled { return }

            await performSearchOn(workspace)
        }
    }

    func performSearchOn(_ workspace: Workspace) async {
        do {
            guard !Task.isCancelled else { return }

            isSearching = true

            defer {
                isSearching = false
            }

            let items = try await interactor.search(workspaceId: workspace.id, text: searchText)

            if !Task.isCancelled {
                searchedItems = items
            }
        } catch is CancellationError {
            return
        } catch {
            print("Erro ao buscar: \(error)")
            searchedItems = []
        }
    }
}
