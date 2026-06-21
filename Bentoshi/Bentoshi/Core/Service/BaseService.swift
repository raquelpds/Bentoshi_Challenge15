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
    
    func query(descriptor: FetchDescriptor<T>? = nil) throws -> [T] {
        if let descriptor {
            return try context.fetch(descriptor)
        } else {
            let fetchAllDescriptor = FetchDescriptor<T>()
            return try context.fetch(fetchAllDescriptor)
        }
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
