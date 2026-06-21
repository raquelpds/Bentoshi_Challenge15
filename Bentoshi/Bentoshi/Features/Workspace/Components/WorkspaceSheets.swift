//
//  WorkspaceSheets.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 20/06/26.
//

import SwiftUI

struct WorkspaceSheetsModifier: ViewModifier {
    @Binding var route: WorkspaceRoute?
    let workspace: Workspace
    let presenter: WorkspacePresenter
    @Binding var shouldReloadWorkspaces: Bool
    
    func body(content: Content) -> some View {
        content
            .sheet(item: $route) { route in
                switch route {
                case .editWorkspace:
                    EditWorkspaceView(workspace: workspace) { workspace, newName, newCoverColor in
                        Task {
                            await presenter.updateWorkspace(
                                workspace,
                                newName: newName ?? workspace.name,
                                newCoverColor: newCoverColor ?? workspace.coverColor
                            )
                            shouldReloadWorkspaces = true
                        }
                    }
                    
                case .newArchive:
                    FilePicker { fileUrl, fileName in
                        Task {
                            await presenter.addArtefact(
                                to: workspace,
                                payload: .archive(url: fileUrl, name: fileName)
                            )
                        }
                    }
                    
                case .updateArchive(let artefact):
                    FilePicker { fileUrl, fileName in
                        Task {
                            await presenter.updateArchiveArtefact(
                                artefact,
                                newURL: fileUrl,
                                newName: fileName
                            )
                        }
                    }
                }
            }
    }
}

extension View {
    func workspaceSheets(
        route: Binding<WorkspaceRoute?>,
        workspace: Workspace,
        presenter: WorkspacePresenter,
        shouldReloadWorkspaces: Binding<Bool>
    ) -> some View {
        modifier(
            WorkspaceSheetsModifier(
                route: route,
                workspace: workspace,
                presenter: presenter,
                shouldReloadWorkspaces: shouldReloadWorkspaces
            )
        )
    }
}
