//
//  WorkspacePresenter.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

import SwiftUI
import SwiftData

@Observable
final class WorkspacePresenter {
    private let interactor: WorkspaceInteractor
    
    var allWorkspaces: [Workspace] = []
    
    func loadWorkspaces() async {
        do {
            allWorkspaces = try await interactor.fetchAllWorkspaces()
        } catch {
            print(error)
        }
    }

    func deleteWorkspace(_ workspace: Workspace) async {
        do {
            try await interactor.deleteWorkspace(id: workspace.id)

        } catch {
            print("Erro ao deletar workspace")
        }
    }
    
    func updateWorkspace(
        _ workspace: Workspace,
        newName: String,
        newCoverColor: WorkspaceColor
    ) async {

        workspace.name = newName
        workspace.coverColor = newCoverColor

        do {
            try await interactor.updateWorkspace()
            await loadWorkspaces()
        } catch {
            print("Erro ao atualizar workspace")
        }
    }
    
    init(interactor: WorkspaceInteractor) {
        self.interactor = interactor
    }
    
    func addFileArtefactType(at workspace: Workspace, archiveUrl: URL, withName name: String) async {
        do {
            let bookmark = try archiveUrl.bookmarkData(
                options: [.withSecurityScope],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            
            let artefact = Artefact(name: name, type: .archive, content: archiveUrl.lastPathComponent, width: 100, height: 100, positionX: 0, positionY: 0, bookmark: bookmark)
            
            workspace.artefacts.append(artefact)
            
            try await interactor.updateWorkspace()
            await loadWorkspaces()
        } catch {
            print(error)
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
            await loadWorkspaces()
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

            try await interactor.updateWorkspace()
            await loadWorkspaces()

        } catch {
            print("Erro ao atualizar arquivo: \(error)")
        }
    }
}
