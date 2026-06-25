//
//  WorkspacePresenter.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

import SwiftUI
import SwiftData

enum ArtefactCreatePayload {
    case archive(url: URL, name: String)
    case link(url: String, name: String)
    case text(title: String, content: String)
}

enum ArtefactUpdatePayload {
    case archive(newURL: URL, newName: String)
    case link(newURL: String, newName: String)
    case text(newTitle: String, newContent: String)
}

@Observable
final class WorkspacePresenter {
    private let interactor: WorkspaceInteractor
    
    var searchedItems: [SearchIndex] = []
    var searchText: String = ""
    var isSearching = false
    var isSearchBarExpanded = false

    private let searchDebouncer = SearchDebouncer()
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
    
    func addArtefact(to workspace: Workspace, payload: ArtefactCreatePayload) async {
        switch payload {

        case .archive(let url, let name):
            await addArchiveArtefact(
                to: workspace,
                archiveUrl: url,
                withName: name
            )

        case .link(let url, let name):
            await addLinkArtefact(
                to: workspace,
                url: url,
                withName: name
            )

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
            
            let artefact = Artefact(
                name: name,
                type: .archive,
                content: archiveUrl.lastPathComponent,
                workspaceId: workspace.id,
                row: 0,
                column: 0,
                width: ArtefactType.archive.initialWidth,
                height: ArtefactType.archive.initialHeight,
                bookmark: bookmark
            )
            
            workspace.artefacts.append(artefact)
            
            try await interactor.updateWorkspace(workspace)
        } catch {
            print(error)
        }
    }
    
    func addLinkArtefact(to workspace: Workspace, url: String, withName name: String) async {
        do {
            let artefact = Artefact(
                name: name,
                type: .link,
                content: url,
                workspaceId: workspace.id,
                row: 0,
                column: 0,
                width: ArtefactType.link.initialWidth,
                height: ArtefactType.link.initialHeight
            )
            
            workspace.artefacts.append(artefact)
            
            try await interactor.updateWorkspace(workspace)
        } catch {
            print(error)
        }
    }
    
    func updateArtefact(_ artefact: Artefact, payload: ArtefactUpdatePayload) async{
        switch payload {

        case .archive(let newUrl, let newName):
            await updateArchiveArtefact(
                artefact,
                newUrl: newUrl,
                newName: newName
            )

        case .link(let newUrl, let newName):
            await updateLinkArtefact(
                artefact,
                newUrl: newUrl,
                newName: newName
            )

        case .text(let name, let content):
            // await addTextArtefact(to: workspace, title: title, content: content)
            break // apagar essa linha depois que implementar
        }
    }
    
    func updateArchiveArtefact(_ artefact: Artefact, newUrl: URL, newName: String) async {
        do {
            artefact.name = newName
            artefact.bookmark = try newUrl.bookmarkData(
                options: [.withSecurityScope],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )

            try await interactor.updateArtefact(artefact)

        } catch {
            print("Erro ao atualizar arquivo: \(error)")
        }
    }
    
    func updateLinkArtefact(_ artefact: Artefact, newUrl: String, newName: String) async {
        do {
            artefact.name = newName
            artefact.content = newUrl
            try await interactor.updateArtefact(artefact)

        } catch {
            print("Erro ao atualizar arquivo: \(error)")
        }
    }
    
    func open(_ artefact: Artefact) {
        switch artefact.type {
        case .archive:
            openArchive(artefact)

        case .link:
            openLink(artefact)

        case .text:
            // openTextEditor(artefact)
            break // apagar essa linha depois que implementar
        }
    }
    
    func openArchive(_ artefact: Artefact) {
        
        guard let url = artefact.archiveUrl else { return }
        
        SystemLauncher.open(url)
    }
    
    func openLink(_ artefact: Artefact){
        guard let url = artefact.linkUrl else { return }
        
        SystemLauncher.open(url)
        
    }
    
    func deleteArtefact(_ artefact: Artefact, from workspace: Workspace) async {
        do {
            try await interactor.deleteArtefact(id: artefact.id, from: workspace)
        } catch {
            print("Erro ao deletar artefato: \(error)")
        }
    }
    
    func revealArchiveInFinder(_ artefact: Artefact) {
        guard let url = artefact.archiveUrl else { return }

        SystemLauncher.revealInFinder(url)
    }
    
    func onSearchTextChangedOn(_ workspace: Workspace) {
        let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedText.isEmpty else {
            searchedItems = []
            isSearching = false
            searchDebouncer.cancel()
            return
        }

        searchDebouncer.run {
            await self.performSearchOn(workspace)
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
