//
//  MenuBarPresenter.swift
//  Bentoshi
//
//  Created by Ana Luisa Teixeira Coleone Reis on 23/06/26.
//

import SwiftUI
import SwiftData

@Observable
final class MenuBarPresenter {
    private let interactor: MenuBarInteractor
    
    init(interactor: MenuBarInteractor) {
        self.interactor = interactor
    }
    
    func addArtefact(to workspace: Workspace, payload: ArtefactCreatePayload) async {
        switch payload {

        case .archive(let url, let name, let keywords):
            await addArchiveArtefact(
                to: workspace,
                archiveUrl: url,
                withName: name,
            )

        case .link(let url, let name, let keywords):
            await addLinkArtefact(
                to: workspace,
                url: url,
                withName: name,
            )

        case .text(let name, let content):
            return
        }
    }
    
    func addArchiveArtefact(to workspace: Workspace, archiveUrl: URL, withName name: String) async {
        do {
            let bookmark = try archiveUrl.bookmarkData(
                options: [.withSecurityScope],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            
            let artefact = Artefact(
                name: name,
                type: .archive,
                content: archiveUrl.lastPathComponent,
                workspaceId: workspace.id,
                row: 0,
                column: 0,
                width: ArtefactType.archive.initialWidth,
                height: ArtefactType.archive.initialHeight,
                bookmark: bookmark
            )
            
            workspace.artefacts.append(artefact)
            
            try await interactor.updateWorkspace()
        } catch {
            print(error)
        }
    }
    
    func addLinkArtefact(to workspace: Workspace, url: String, withName name: String) async {
        do {
            let artefact = Artefact(
                name: name,
                type: .link,
                content: url,
                workspaceId: workspace.id,
                row: 0,
                column: 0,
                width: ArtefactType.link.initialWidth,
                height: ArtefactType.link.initialHeight
            )
            
            workspace.artefacts.append(artefact)
            
            try await interactor.updateWorkspace()
        } catch {
            print(error)
        }
    }
}
