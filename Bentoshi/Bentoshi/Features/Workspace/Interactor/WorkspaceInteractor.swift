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

//raquel
extension WorkspaceInteractor {
    
    func moveArtefact(
        _ artefact: Artefact,
        in workspace: Workspace,
        to row: Int,
        column: Int
    ) async throws {
        guard isPlacementValid(
            artefact: artefact,
            in: workspace,
            row: row,
            column: column,
            width: artefact.width,
            height: artefact.height
        ) else {
            return
        }
        
        artefact.gridRow = row
        artefact.gridColumn = column
        artefact.updatedAt = Date()
        artefact.workspace?.updatedAt = Date()
        
        try await updateArtefact(artefact)
    }
    
    func resizeArtefact(
        _ artefact: Artefact,
        in workspace: Workspace,
        width: Int,
        height: Int
    ) async throws {
        let newWidth = max(
            artefact.type.initialWidth,
            width
        )
        
        let newHeight = max(
            artefact.type.initialHeight,
            height
        )
        
        guard isPlacementValid(
            artefact: artefact,
            in: workspace,
            row: artefact.gridRow,
            column: artefact.gridColumn,
            width: newWidth,
            height: newHeight
        ) else {
            return
        }
        
        artefact.width = newWidth
        artefact.height = newHeight
        artefact.updatedAt = Date()
        artefact.workspace?.updatedAt = Date()
        
        try await updateArtefact(artefact)
    }
    
    private func isPlacementValid(
        artefact: Artefact,
        in workspace: Workspace,
        row: Int,
        column: Int,
        width: Int,
        height: Int
    ) -> Bool {
        let columns = 20
        
        if row < 0 ||
            column < 0 ||
            width <= 0 ||
            height <= 0 ||
            column + width > columns {
            return false
        }
        
        for other in workspace.artefacts {
            if other.id == artefact.id {
                continue
            }
            
            let overlaps = !(
                column + width <= other.gridColumn ||
                column >= other.gridColumn + other.width ||
                row + height <= other.gridRow ||
                row >= other.gridRow + other.height
            )
            
            if overlaps {
                return false
            }
        }
        
        return true
    }
}
