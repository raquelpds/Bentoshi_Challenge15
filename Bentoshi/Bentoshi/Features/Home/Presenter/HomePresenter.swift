//
//  WorkspacePresenter.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

import SwiftUI
import SwiftData

@Observable
final class HomePresenter {
    private let interactor: HomeInteractor

    var workspaces: [Workspace] = []
    var searchedItems: [SearchIndex] = []
    var searchText: String = ""
    var isSearching = false
    var isSearchBarExpanded = false

    private var searchTask: Task<Void, Never>?

    init(interactor: HomeInteractor) {
        self.interactor = interactor
    }

    func addWorkspace(_ workspace: Workspace) async {
        do {
            try await interactor.createWorkspace(workspace)
        } catch {
            print("Erro ao adicionar workspaces")
        }
    }

    func deleteWorkspace(_ workspace: Workspace) async {
        do {
            try await interactor.deleteWorkspace(id: workspace.id)
        } catch {
            print("Erro ao deletar workspaces")
        }
    }

    func updateWorkspace(_ workspace: Workspace, newName: String, newCoverColor: WorkspaceColor) async {
        workspace.name = newName
        workspace.coverColor = newCoverColor

        do {
            try await interactor.updateWorkspace()
        } catch {
            print("Erro ao atualizar workspace")
        }
    }

    func onSearchTextChanged() {
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

            await performSearch()
        }
    }

    func performSearch() async {
        do {
            guard !Task.isCancelled else { return }

            isSearching = true

            defer {
                isSearching = false
            }

            let items = try await interactor.search(text: searchText)

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
}
