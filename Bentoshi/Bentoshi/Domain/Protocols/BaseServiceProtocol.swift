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
    func query(descriptor: FetchDescriptor<Entity>?) throws -> [Entity]
    func fetchById(_ id: PersistentIdentifier) throws -> Entity?
    
}
