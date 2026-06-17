//
//  TransactionRepositoryProtocol.swift
//  HeyMoni
//
//  Created by Lizandra Malta on 02/05/26.
//

import Foundation
import SwiftData

protocol WorkspaceServiceProtocol {
    
    func create(_ workspace: Workspace) throws
    func delete(id: PersistentIdentifier) throws
    func update() throws 
    func fetchAll() throws -> [Workspace]
    func fetchById(_ id: PersistentIdentifier) throws -> Workspace?
    
}
