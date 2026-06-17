//
//  HomeBuilder.swift
//  PocReferenciaArquivos+VIP
//
//  Created by Lizandra Malta on 16/06/26.
//

import SwiftData

enum HomeBuilder {

    @MainActor
    static func build(context: ModelContext) -> HomeView {

        let workspaceService: WorkspaceServiceProtocol = WorkspaceService(context: context)

        let interactor = HomeInteractor(
            workspaceService: workspaceService
        )

        let presenter = HomePresenter(
            interactor: interactor
        )

        return HomeView(
            presenter: presenter
        )
    }
}
