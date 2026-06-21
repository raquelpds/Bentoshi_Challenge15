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
    
    func body(content: Content) -> some View {
        content
            .sheet(item: $route) { route in
                switch route {
                case .editWorkspace:
                    WorkspaceFormView(mode: .edit(workspace)) { workspace, name, color in
                        Task {
                            await presenter.updateWorkspace(
                                workspace,
                                newName: name,
                                newCoverColor: color
                            )
                        }
                    }
                    
                case .newArchive:
                    FilePicker(mode: .create) { fileUrl, fileName in
                        Task {
                            await presenter.addArtefact(
                                to: workspace,
                                payload: .archive(url: fileUrl, name: fileName)
                            )
                        }
                    }
                    
                case .updateArchive(let artefact):
                    FilePicker(mode: .edit(artefact)) { fileUrl, fileName in
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
    ) -> some View {
        modifier(
            WorkspaceSheetsModifier(
                route: route,
                workspace: workspace,
                presenter: presenter,
            )
        )
    }
}
