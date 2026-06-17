//
//  TransactionRepositoryProtocol.swift
//  HeyMoni
//
//  Created by Lizandra Malta on 02/05/26.
//

import Foundation
import SwiftData

protocol BaseServiceProtocol {
    associatedtype Entity: PersistentModel
    
    func insert(_ entity: Entity) throws
    func remove(id: PersistentIdentifier) throws
    func save() throws
    func query(predicate: Predicate<Entity>?, sortBy: [SortDescriptor<Entity>], fetchLimit: Int?) throws -> [Entity]
    func fetchById(_ id: PersistentIdentifier) throws -> Entity?
    
}
