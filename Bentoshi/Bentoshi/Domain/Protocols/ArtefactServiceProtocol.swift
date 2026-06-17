//
//  TransactionRepositoryProtocol.swift
//  HeyMoni
//
//  Created by Lizandra Malta on 02/05/26.
//

import Foundation
import SwiftData

protocol ArtefactServiceProtocol {
    
    func delete(id: PersistentIdentifier) throws
    func update() throws 
    func fetchById(_ id: PersistentIdentifier) throws -> Artefact?
    
}
