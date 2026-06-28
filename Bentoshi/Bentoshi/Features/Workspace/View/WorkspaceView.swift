//
//  WorkspaceDetailView.swift
//  WorkspaceBento
//
//  Created by Rebeca Maria de Morais Guimães on 16/06/26.
//

import SwiftUI
import SwiftData

enum WorkspaceSheetRoute: Identifiable {
    case editWorkspace
    case newArchive
    case newLink
    case updateArchive(Artefact)
    case updateLink(Artefact)
    
    var id: String {
        switch self {
        case .editWorkspace:
            "editWorkspace"
        case .newArchive:
            "newArchive"
        case .newLink:
            "newLink"
        case .updateArchive(let artefact):
            "updateArchive-\(artefact.id)"
        case .updateLink(let artefact):
            "updateLink-\(artefact.id)"
        }
    }
}

enum WorkspaceDetailRoute {
    case newText
    case updateText(Artefact)
    
    var id: String {
        switch self {
        case .newText:
            "newText"
        case .updateText(let artefact):
            "updateText-\(artefact.id)"
        }
    }
}

enum WorkspaceAlert: Identifiable {
    case deleteWorkspace
    case deleteArtefact(Artefact)
    case missingArchive(Artefact)
    case invalidLink(Artefact)
    
    var id: String {
        switch self {
        case .deleteWorkspace:
            "deleteWorkspace"
        case .deleteArtefact(let artefact):
            "deleteArtefact-\(artefact.id)"
        case .missingArchive(let artefact):
            "missingArchive-\(artefact.id)"
        case .invalidLink(let artefact):
            "invalidLink-\(artefact.id)"
        }
    }
}

struct WorkspaceView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var workspaces: [Workspace]
    
    @State var presenter: WorkspacePresenter
    @State private var selectedID: Workspace.ID?
    @State private var sheetRoute: WorkspaceSheetRoute?
    @State private var detailRoute: WorkspaceDetailRoute?
    @State private var alert: WorkspaceAlert?
    
    let workspace: Workspace
    
    private var current: Workspace {
        workspaces.first { $0.id == selectedID } ?? workspace
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationSplitView {
                WorkspaceSidebar(
                    workspaces: workspaces,
                    selectedID: $selectedID
                )
            } detail: {
                ZStack {
                    WorkspaceDetailContent(
                        workspace: current,
                        presenter: presenter,
                        sheetRoute: $sheetRoute,
                        detailRoute: $detailRoute,
                        alert: $alert
                    )
                    .opacity(isSearchActive ? 0 : 1)
                    .allowsHitTesting(!isSearchActive)
                    
                    WorkspaceSearchContent(
                        workspace: current,
                        presenter: presenter
                    )
                    .opacity(isSearchActive ? 1 : 0)
                    .allowsHitTesting(isSearchActive)
                }
                .navigationTitle(current.name)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        SearchToolbarItem(
                            searchText: $presenter.searchText,
                            isExpanded: $presenter.isSearchBarExpanded
                        )
                    }
                    
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button {
                                sheetRoute = .editWorkspace
                            } label: {
                                Label("Editar", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                alert = .deleteWorkspace
                            } label: {
                                Label("Excluir", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                        .menuIndicator(.hidden)
                    }
                }
            }
            
            FloatingAddButton { action in
                switch action {
                case .archive:
                    sheetRoute = .newArchive
                case .text:
                    detailRoute = .newText
                    break
                case .link:
                    sheetRoute = .newLink
                }
            }
        }
        .onChange(of: presenter.searchText) { _, _ in
            presenter.onSearchTextChangedOn(current)
        }
        .workspaceSheets(
            route: $sheetRoute,
            workspace: current,
            presenter: presenter
        )
        .workspaceAlerts(
            alert: $alert,
            route: $sheetRoute,
            workspace: current,
            presenter: presenter,
            onDeleteWorkspace: deleteCurrentWorkspace
        )
        .onAppear {
            selectedID = selectedID ?? workspace.id
        }
    }
    
    private var isSearchActive: Bool {
        !presenter.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension WorkspaceView {
    
    private func deleteCurrentWorkspace() {
        let workspaceToDelete = current
        
        Task {
            await presenter.deleteWorkspace(workspaceToDelete)
            
            if let nextWorkspace = workspaces.first {
                selectedID = nextWorkspace.id
            } else {
                dismiss()
            }
        }
    }
    
}

#Preview {
    struct PreviewWithContextWrapper: View {
        @Environment(\.modelContext) private var context
        var body: some View {
            WorkspaceBuilder.build(context: context, workspace: Workspace(name: "Teste"))
        }
    }
    
    return PreviewWithContextWrapper()
}
