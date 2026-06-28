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

enum WorkspaceDetailRoute: Identifiable {
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
            // Se tem detailRoute, mostra 3 colunas. Senão, 2 colunas
            if detailRoute != nil {
                NavigationSplitView {
                    // COLUNA 1: Sidebar com workspaces
                    WorkspaceSidebar(
                        workspaces: workspaces,
                        selectedID: $selectedID
                    )
                } content: {
                    // COLUNA 2: Conteúdo do workspace
                    contentView
                        .navigationTitle(current.name)
                        .toolbar {
                            ToolbarItem(placement: .primaryAction) {
                                SearchToolbarItem(
                                    searchText: $presenter.searchText,
                                    isExpanded: $presenter.isSearchBarExpanded
                                )
                            }
                            
                            ToolbarItem(placement: .primaryAction) {
                                workspaceMenu
                            }
                        }
                } detail: {
                    // COLUNA 3: Editor de texto lateral
                    if let detailRoute = detailRoute {
                        textEditorPanel(for: detailRoute)
                            .navigationSplitViewColumnWidth(
                                min: 400,
                                ideal: 500,
                                max: 600
                            )
                    }
                }
            } else {
                NavigationSplitView {
                    // COLUNA 1: Sidebar com workspaces
                    WorkspaceSidebar(
                        workspaces: workspaces,
                        selectedID: $selectedID
                    )
                } detail: {
                    // Só 2 colunas quando sem editor
                    contentView
                        .navigationTitle(current.name)
                        .toolbar {
                            ToolbarItem(placement: .primaryAction) {
                                SearchToolbarItem(
                                    searchText: $presenter.searchText,
                                    isExpanded: $presenter.isSearchBarExpanded
                                )
                            }
                            
                            ToolbarItem(placement: .primaryAction) {
                                workspaceMenu
                            }
                        }
                }
            }
            
            FloatingAddButton { action in
                switch action {
                case .archive:
                    sheetRoute = .newArchive
                case .text:
                    detailRoute = .newText
                case .link:
                    sheetRoute = .newLink
                }
            }
            .opacity(detailRoute == nil ? 1 : 0)
            .allowsHitTesting(detailRoute == nil)
        }
        .onChange(of: presenter.searchText) { _, _ in
            presenter.onSearchTextChangedOn(current)
        }
        .onDisappear {
            // Reseta o editor ao sair do workspace
            detailRoute = nil
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
    
    private var contentView: some View {
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
    }
    
    private var workspaceMenu: some View {
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
    
    @ViewBuilder
    private func textEditorPanel(for route: WorkspaceDetailRoute) -> some View {
        switch route {
        case .newText:
            TextEditorSheet(
                mode: .create,
                onSave: { title, formattedText in
                    Task {
                        await presenter.addArtefact(
                            to: current,
                            payload: .text(title: title, content: formattedText)
                        )
                        detailRoute = nil
                    }
                },
                onCancel: {
                    detailRoute = nil
                }
            )
            
        case .updateText(let artefact):
            TextEditorSheet(
                mode: .edit(artefact),
                onSave: { title, formattedText in
                    Task {
                        await presenter.updateArtefact(
                            artefact,
                            payload: .text(newTitle: title, newContent: formattedText)
                        )
                        detailRoute = nil
                    }
                },
                onCancel: {
                    detailRoute = nil
                }
            )
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
