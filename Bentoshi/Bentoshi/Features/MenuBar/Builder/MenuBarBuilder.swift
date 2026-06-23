//
//  MenuBarBuilder.swift
//  Bentoshi
//
//  Created by Ana Luisa Teixeira Coleone Reis on 23/06/26.
//

import SwiftData
import SwiftUI

enum MenuBarBuilder {

    @MainActor
    static func build(context: ModelContext) -> MenuBarPresenter {

        let workspaceService: WorkspaceServiceProtocol = WorkspaceService(context: context)

        let interactor = MenuBarInteractor(
            workspaceService: workspaceService,
        )

        return MenuBarPresenter(
            interactor: interactor
        )
    }
}
