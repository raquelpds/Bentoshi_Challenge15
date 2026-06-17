//
//  SwiftDataService.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

import Foundation
import SwiftData

struct StorageService<T: PersistentModel>: BaseServiceProtocol {
    
    typealias Entity = T
    
    private var context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func insert(_ entity: T) throws {
        context.insert(entity)
        try context.save()
    }
    
    func remove(id: PersistentIdentifier) throws {
        guard let entity = try fetchById(id) else { return }
        context.delete(entity)
        try context.save()
    }
    
    func save() throws {
        try context.save()
    }
    
    func query(
        predicate: Predicate<T>? = nil,
        sortBy: [SortDescriptor<Entity>] = [],
        fetchLimit: Int? = nil
    ) throws -> [T] {
        var descriptor = FetchDescriptor<T>(
            predicate: predicate,
            sortBy: sortBy
        )
        
        if let fetchLimit {
            descriptor.fetchLimit = fetchLimit
        }
        
        return try context.fetch(descriptor)
    }
    
    func fetchById(
        _ id: PersistentIdentifier
    ) throws -> T? {
        let descriptor = FetchDescriptor<T>(
            predicate: #Predicate { $0.persistentModelID == id }
        )
        return try context.fetch(descriptor).first
    }
    
}
