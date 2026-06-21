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
    
}
