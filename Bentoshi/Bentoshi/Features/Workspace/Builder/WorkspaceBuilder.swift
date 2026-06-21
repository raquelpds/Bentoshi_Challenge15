//
//  HomeBuilder.swift
//  PocReferenciaArquivos+VIP
//
//  Created by Lizandra Malta on 16/06/26.
//

import SwiftData
import SwiftUI

enum WorkspaceBuilder {

    @MainActor
    static func build(context: ModelContext, workspace: Workspace) -> WorkspaceView {

        let workspaceService: WorkspaceServiceProtocol = WorkspaceService(context: context)
        
        let artefactService: ArtefactServiceProtocol = ArtefactService(context: context)

        let interactor = WorkspaceInteractor(
            workspaceService: workspaceService,
            artefactService: artefactService
        )

        let presenter = WorkspacePresenter(
            interactor: interactor
        )

        return WorkspaceView(
            presenter: presenter,
            workspace: workspace
        )
    }
}
