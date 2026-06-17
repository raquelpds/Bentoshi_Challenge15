//
//  WorkspaceService.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

import SwiftData

final class ArtefactService: ArtefactServiceProtocol {
    
    private let storage: StorageService<Artefact>
    
    init(context: ModelContext) {
        self.storage = StorageService(context: context)
    }
    
    func delete(id: PersistentIdentifier) throws {
        try storage.remove(id: id)
    }
    
    func update() throws {
        try storage.save()
    }
    
    func fetchById(_ id: PersistentIdentifier) throws -> Artefact? {
        try storage.fetchById(id)
    }
}
