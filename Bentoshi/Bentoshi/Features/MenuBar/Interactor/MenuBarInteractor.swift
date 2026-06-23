//
//  MenuBarInteractor.swift
//  Bentoshi
//
//  Created by Ana Luisa Teixeira Coleone Reis on 23/06/26.
//

import Foundation
import SwiftUI

final class MenuBarInteractor {
    private let workspaceService: WorkspaceServiceProtocol
    
    init(workspaceService: WorkspaceServiceProtocol) {
        self.workspaceService = workspaceService
    }
    
    func updateWorkspace() async throws {
        try workspaceService.update()
    }
    
}
