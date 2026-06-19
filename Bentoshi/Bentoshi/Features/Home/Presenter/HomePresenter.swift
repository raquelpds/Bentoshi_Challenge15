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
    
    func listWorkspaces() async {
        do {
            workspaces = try await interactor.fetchAllWorkspaces()

            print("TOTAL:", workspaces.count)
        } catch {
            print(error)
        }
    }
    
    func addWorkspace(_ workspace: Workspace) async {
        do {
            try await interactor.createWorkspace(workspace)
            await listWorkspaces()
        } catch {
            print("Erro ao adicionar workspaces")
        }
    }
    
    func deleteWorkspace(_ workspace: Workspace) async {
        do {
            try await interactor.deleteWorkspace(id: workspace.id)
            await listWorkspaces()
        } catch {
            print("Erro ao deletar workspaces")
        }
    }
    
    
}
