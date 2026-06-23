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
                
                case .newLink:
                    LinkFormSheet(mode: .create) { url, name in
                        Task {
                            await presenter.addArtefact(
                                to: workspace,
                                payload: .link(url: url, name: name)
                            )
                        }
                    }
                    
                case .updateArchive(let artefact):
                    FilePicker(mode: .edit(artefact)) { fileUrl, fileName in
                        Task {
                            await presenter.updateArtefact(
                                artefact,
                                payload: .archive(
                                    newURL: fileUrl,
                                    newName: fileName
                                )
                            )
                        }
                    }
                
            case .updateLink(let artefact):
                LinkFormSheet(mode: .edit(artefact)) { url, name in
                    Task {
                        await presenter.updateArtefact(
                            artefact,
                            payload: .link(
                                newURL: url,
                                newName: name
                            )
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
