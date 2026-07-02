//
//  HomeInteractor.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

import SwiftData
import Foundation

final class HomeInteractor {
    
    private let workspaceService: WorkspaceServiceProtocol
    private let searchIndexService: SearchIndexServiceProtocol
    
    init(workspaceService: WorkspaceServiceProtocol, searchIndexService: SearchIndexServiceProtocol) {
        self.workspaceService = workspaceService
        self.searchIndexService = searchIndexService
    }
    
    func updateWorkspace(_ workspace: Workspace) async throws {
        
        try searchIndexService.deleteAutomaticIndexes(indexes: workspace.searchIndexes)
        
        workspace.rebuildSearchIndexes()
        workspace.updatedAt = Date()
        
        try workspaceService.update()
    }
    
    func createWorkspace(_ workspace: Workspace) async throws {
        try workspaceService.create(workspace)
    }
    
    func deleteWorkspace(id: PersistentIdentifier) async throws {
        try workspaceService.delete(id: id)
    }
    
    func search(text: String) async throws -> [SearchIndex] {
        return try searchIndexService.globalSearch(text)
    }
    
}
