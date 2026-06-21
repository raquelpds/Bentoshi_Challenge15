//
//  WorkspaceSheets.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 20/06/26.
//

import SwiftUI

struct WorkspaceAlertsModifier: ViewModifier {
    @Binding var alert: WorkspaceAlert?
    @Binding var route: WorkspaceRoute?

    let workspace: Workspace
    let presenter: WorkspacePresenter

    func body(content: Content) -> some View {
        content
            .alert(item: $alert) { alert in
                switch alert {

                case .deleteWorkspace:
                    Alert(
                        title: Text("Excluir workspace?"),
                        primaryButton: .destructive(Text("Excluir")) {
                            Task {
                                await presenter.deleteWorkspace(workspace)
                            }
                        },
                        secondaryButton: .cancel()
                    )

                case .deleteArtefact(let artefact):
                    Alert(
                        title: Text("Excluir artefato?"),
                        message: Text(artefact.name),
                        primaryButton: .destructive(Text("Excluir")) {
                            Task {
                                await presenter.deleteArtefact(artefact, from: workspace)
                            }
                        },
                        secondaryButton: .cancel()
                    )

                case .missingArchive(let artefact):
                    Alert(
                        title: Text("Arquivo não encontrado"),
                        message: Text(artefact.name),
                        primaryButton: .default(Text("Atualizar")) {
                            route = .updateArchive(artefact)
                        },
                        secondaryButton: .destructive(Text("Excluir")) {
                            Task {
                                await presenter.deleteArtefact(artefact, from: workspace)
                            }
                        }
                    )
                }
            }
    }
}

extension View {
    func workspaceAlerts(
        alert: Binding<WorkspaceAlert?>,
        route: Binding<WorkspaceRoute?>,
        workspace: Workspace,
        presenter: WorkspacePresenter
    ) -> some View {
        modifier(
            WorkspaceAlertsModifier(
                alert: alert,
                route: route,
                workspace: workspace,
                presenter: presenter
            )
        )
    }
}
