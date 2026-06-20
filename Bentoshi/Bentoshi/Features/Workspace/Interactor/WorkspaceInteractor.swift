//
//  HomeInteractor.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

import SwiftData

final class WorkspaceInteractor {
    
    private let workspaceService: WorkspaceServiceProtocol
    private let artefactService: ArtefactServiceProtocol
    
    func fetchAllWorkspaces() async throws -> [Workspace] {
        try workspaceService.fetchAll()
    }
    
    func deleteWorkspace(id: PersistentIdentifier) async throws {
        try workspaceService.delete(id: id)
    }
    
    func updateWorkspace() async throws {
        try workspaceService.update()
    }
    
    init(workspaceService: WorkspaceServiceProtocol, artefactService: ArtefactServiceProtocol) {
        self.workspaceService = workspaceService
        self.artefactService = artefactService
    }
}
