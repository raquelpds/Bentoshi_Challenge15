//
//  WorkspaceDetailView.swift
//  WorkspaceBento
//
//  Created by Rebeca Maria de Morais Guimães on 16/06/26.
//

import SwiftUI
import SwiftData

enum WorkspaceRoute: Identifiable {
    case editWorkspace
    case newArchive
    case newLink
    case newText
    case updateArchive(Artefact)
    case updateLink(Artefact)
    case updateText(Artefact)
    
    var id: String {
        switch self {
        case .editWorkspace:
            "editWorkspace"
        case .newArchive:
            "newArchive"
        case .newLink:
            "newLink"
        case .newText:
            "newText"
        case .updateArchive(let artefact):
            "updateArchive-\(artefact.id)"
        case .updateLink(let artefact):
            "updateLink-\(artefact.id)"
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
    @State private var route: WorkspaceRoute?
    @State private var alert: WorkspaceAlert?
    
    let workspace: Workspace
    let sortOption: SortOption
    
    private var current: Workspace {
        workspaces.first { $0.id == selectedID } ?? workspace
    }
    
    init(presenter: WorkspacePresenter, sortOption: SortOption, workspace: Workspace){
        
        self.presenter = presenter
        self.sortOption = sortOption
        self.workspace = workspace
        
        switch sortOption {
        case .alphabet:
            _workspaces = Query(
                sort: \Workspace.normalizedName,
                order: .forward
            )
        
        case .lastCreated:
            _workspaces = Query(
                sort: \Workspace.createdAt,
                order: .reverse
            )
            
        case .lastModified:
            _workspaces = Query(
                sort: \Workspace.updatedAt,
                order: .reverse
            )
        }
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
                        route: $route,
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
                        Menu {
                            Button {
                                route = .editWorkspace
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
                    route = .newArchive
                case .text:
                    route = .newText
                    break
                case .link:
                    route = .newLink
                }
            }
        }
        .searchable(text: $presenter.searchText)
        .onChange(of: presenter.searchText) { _, _ in
            presenter.onSearchTextChangedOn(current)
        }
        .workspaceSheets(
            route: $route,
            workspace: current,
            presenter: presenter
        )
        .workspaceAlerts(
            alert: $alert,
            route: $route,
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
            WorkspaceBuilder.build(context: context, sortOption: .alphabet,workspace: Workspace(name: "Teste"))
        }
    }
    
    return PreviewWithContextWrapper()
}
