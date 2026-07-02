//
//  HomeInteractor.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

import SwiftData
import Foundation
import AppKit

final class WorkspaceInteractor {
    
    private let workspaceService: WorkspaceServiceProtocol
    private let artefactService: ArtefactServiceProtocol
    private let searchIndexService: SearchIndexServiceProtocol
    
    init(workspaceService: WorkspaceServiceProtocol, artefactService: ArtefactServiceProtocol, searchIndexService: SearchIndexServiceProtocol) {
        self.workspaceService = workspaceService
        self.artefactService = artefactService
        self.searchIndexService = searchIndexService
    }
    
    func fetchAllWorkspaces() async throws -> [Workspace] {
        try workspaceService.fetchAll()
    }
    
    func deleteWorkspace(id: PersistentIdentifier) async throws {
        try workspaceService.delete(id: id)
    }
    
    func updateWorkspace(_ workspace: Workspace) async throws {
        
        try searchIndexService.deleteAutomaticIndexes(indexes: workspace.searchIndexes)
        
        workspace.rebuildSearchIndexes()
        
        workspace.updatedAt = Date()
        
        try workspaceService.update()
    }
    
    func updateArtefact(_ artefact: Artefact) async throws {
        try searchIndexService.deleteAutomaticIndexes(indexes: artefact.searchIndexes)
        
        artefact.rebuildAutomaticSearchIndexes()
        
        artefact.workspace?.updatedAt = Date()
        
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
    
    func search(workspaceId: UUID, text: String) async throws -> [SearchIndex] {
        return try searchIndexService.searchArtefactFromWorkspaceWithId(workspaceId, text: text)
    }
    
}
