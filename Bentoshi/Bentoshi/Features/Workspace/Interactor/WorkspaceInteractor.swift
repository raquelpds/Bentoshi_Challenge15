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
    
    init(workspaceService: WorkspaceServiceProtocol, artefactService: ArtefactServiceProtocol) {
        self.workspaceService = workspaceService
        self.artefactService = artefactService
    }
    
    func fetchAllWorkspaces() async throws -> [Workspace] {
        try workspaceService.fetchAll()
    }
    
    func deleteWorkspace(id: PersistentIdentifier) async throws {
        try workspaceService.delete(id: id)
    }
    
    func updateWorkspace() async throws {
        try workspaceService.update()
    }
    
    func deleteArtefact(id: PersistentIdentifier, from workspace: Workspace) async throws {
        guard let archiveToDeleteIndex = workspace.artefacts.firstIndex(where: { $0.id == id }) else {
            return
        }
        workspace.artefacts.remove(at: archiveToDeleteIndex)
        try workspaceService.update()
        try artefactService.delete(id: id)
    }
}
