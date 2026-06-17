//
//  WorkspaceService.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

import SwiftData

final class WorkspaceService: WorkspaceServiceProtocol {
    
    private let storage: StorageService<Workspace>
    
    init(context: ModelContext) {
        self.storage = StorageService(context: context)
    }
    
    func create(_ workspace: Workspace) throws {
        try storage.insert(workspace)
    }
    
    func delete(id: PersistentIdentifier) throws {
        try storage.remove(id: id)
    }
    
    func update() throws {
        try storage.save()
    }
    
    func fetchAll() throws -> [Workspace] {
        try storage.query()
    }
    
    func fetchById(_ id: PersistentIdentifier) throws -> Workspace? {
        try storage.fetchById(id)
    }
}
