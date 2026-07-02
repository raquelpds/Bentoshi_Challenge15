//
//  WorkspaceSheets.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 20/06/26.


import SwiftUI

struct WorkspaceSheetsModifier: ViewModifier {
    @Binding var route: WorkspaceSheetRoute?
    
    let workspace: Workspace
    let presenter: WorkspacePresenter
    
    func body(content: Content) -> some View {
        content
            .sheet(item: $route) { route in
                switch route {
                case .newArchive:
                    FilePicker(mode: .create) { fileUrl, fileName, keywords in
                        Task {
                            await presenter.addArtefact(
                                to: workspace,
                                payload: .archive(
                                    url: fileUrl,
                                    name: fileName,
                                    keywords: keywords
                                )
                            )
                        }
                    }
                    
                case .newLink:
                    LinkFormSheet(mode: .create) { url, name, keywords in
                        Task {
                            await presenter.addArtefact(
                                to: workspace,
                                payload: .link(
                                    url: url,
                                    name: name,
                                    keywords: keywords
                                )
                            )
                        }
                    }
                    
                case .updateArchive(let artefact):
                    FilePicker(mode: .edit(artefact)) { fileUrl, fileName, keywords in
                        Task {
                            await presenter.updateArtefact(
                                artefact,
                                payload: .archive(
                                    newURL: fileUrl,
                                    newName: fileName,
                                    keywords: keywords
                                )
                            )
                        }
                    }
                    
                case .updateLink(let artefact):
                    LinkFormSheet(mode: .edit(artefact)) { url, name, keywords in
                        Task {
                            await presenter.updateArtefact(
                                artefact,
                                payload: .link(
                                    newURL: url,
                                    newName: name,
                                    keywords: keywords
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
        route: Binding<WorkspaceSheetRoute?>,
        workspace: Workspace,
        presenter: WorkspacePresenter
    ) -> some View {
        modifier(
            WorkspaceSheetsModifier(
                route: route,
                workspace: workspace,
                presenter: presenter
            )
        )
    }
}
