//
//  WorkspaceDetailView.swift
//  WorkspaceBento
//
//  Created by Rebeca Maria de Morais Guimães on 16/06/26.
//

import SwiftUI

enum WorkspaceRoute: Identifiable {
    case editWorkspace
    case newArchive
    case updateArchive(Artefact)

    var id: String {
        switch self {
        case .editWorkspace:
            "editWorkspace"
        case .newArchive:
            "newArchive"
        case .updateArchive(let artefact):
            "updateArchive-\(artefact.id)"
        }
    }
}

enum WorkspaceAlert: Identifiable {
    case deleteWorkspace
    case deleteArtefact(Artefact)
    case missingArchive(Artefact)

    var id: String {
        switch self {
        case .deleteWorkspace:
            "deleteWorkspace"
        case .deleteArtefact(let artefact):
            "deleteArtefact-\(artefact.id)"
        case .missingArchive(let artefact):
            "missingArchive-\(artefact.id)"
        }
    }
}

struct WorkspaceView: View {
    @Environment(\.dismiss) private var dismiss

    @State var presenter: WorkspacePresenter
    @State private var selectedID: Workspace.ID?
    @State private var route: WorkspaceRoute?
    @State private var alert: WorkspaceAlert?
    @Binding var shouldReloadWorkspaces: Bool

    let workspace: Workspace

    private var current: Workspace {
        presenter.allWorkspaces.first { $0.id == selectedID } ?? workspace
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationSplitView {
                WorkspaceSidebar(
                    workspaces: presenter.allWorkspaces,
                    selectedID: $selectedID
                )
            } detail: {
                WorkspaceDetailContent(
                    workspace: current,
                    presenter: presenter,
                    route: $route,
                    alert: $alert
                )
            }

            FloatingAddButton { action in
                switch action {

                case .archive:
                    route = .newArchive

                case .text:
//                    route = .newText
                    break // apagar essa linha depois que implementar

                case .link:
//                    route = .newLink
                    break // apagar essa linha depois que implementar
                }
            }
        }
        .workspaceSheets(
            route: $route,
            workspace: current,
            presenter: presenter,
            shouldReloadWorkspaces: $shouldReloadWorkspaces
        )
        .workspaceAlerts(
            alert: $alert,
            route: $route,
            workspace: current,
            presenter: presenter
        )
        .onAppear {
            selectedID = selectedID ?? workspace.id
        }
        .task {
            await presenter.loadWorkspaces()
        }
    }
}

#Preview {
    struct PreviewWithContextWrapper: View {
        @Environment(\.modelContext) private var context
        var body: some View {
            WorkspaceBuilder.build(context: context, workspace: Workspace(name: "Teste"), shouldReloadWorkspace: .constant(true))
        }
    }
    
    return PreviewWithContextWrapper()
}
