//
//  HomeInteractor.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

import SwiftData

final class HomeInteractor {
    
    private let workspaceService: WorkspaceServiceProtocol
    
    init(workspaceService: WorkspaceServiceProtocol) {
        self.workspaceService = workspaceService
    }
    
    func fetchAllWorkspaces() async throws -> [Workspace] {
        return try workspaceService.fetchAll()
    }
    
    func updateWorkspace() async throws {
        try workspaceService.update()
    }
    
    func createWorkspace(_ workspace: Workspace) async throws {
        try workspaceService.create(workspace)
    }
    
    func deleteWorkspace(id: PersistentIdentifier) async throws {
        try workspaceService.delete(id: id)
    }
    
    
    
}
