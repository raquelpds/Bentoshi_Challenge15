//
//  TransactionRepositoryProtocol.swift
//  HeyMoni
//
//  Created by Lizandra Malta on 02/05/26.
//

import Foundation
import SwiftData

protocol SearchIndexServiceProtocol {
    
    func delete(id: PersistentIdentifier) throws
    func deleteAutomaticIndexes(indexes: [SearchIndex]) throws
    func globalSearch(_ text: String) throws -> [SearchIndex]
    func searchArtefactFromWorkspaceWithId(_ id: UUID, text: String) throws -> [SearchIndex]
    
}
