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
        newName: String
    ) async {

        workspace.name = newName

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
}
