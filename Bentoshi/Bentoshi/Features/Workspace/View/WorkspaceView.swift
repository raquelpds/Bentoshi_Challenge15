//
//  WorkspaceDetailView.swift
//  WorkspaceBento
//
//  Created by Rebeca Maria de Morais Guimães on 16/06/26.
//

import SwiftUI
import SwiftData

enum WorkspaceSheetRoute: Identifiable {
    case newArchive
    case newLink
    case updateArchive(Artefact)
    case updateLink(Artefact)
    
    var id: String {
        switch self {
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
    @State private var showColorPickerPopover = false
    
    let sortOption: SortOption
    var current: Workspace? {
        workspaces.first {$0.id == selectedID}
    }
    
    init(presenter: WorkspacePresenter, sortOption: SortOption, workspace: Workspace) {
        _presenter = State(initialValue: presenter)
        _selectedID = State(initialValue: workspace.id)
        
        self.sortOption = sortOption
        
        switch sortOption {
        case .alphabet:
            _workspaces = Query(sort: \Workspace.normalizedName, order: .forward)
            
        case .lastCreated:
            _workspaces = Query(sort: \Workspace.createdAt, order: .reverse)
            
        case .lastModified:
            _workspaces = Query(sort: \Workspace.updatedAt, order: .reverse)
        }
    }
    
    var body: some View {
        if let current {
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
            .searchable(text: $presenter.searchText)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showColorPickerPopover.toggle()
                    } label: {
                        Image(systemName: "paintpalette")
                    }
                    .popover(isPresented: $showColorPickerPopover, arrowEdge: .top) {
                        ColorPickerPopover(workspace: current, presenter: presenter)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(role: .destructive) {
                            deleteCurrentWorkspace()
                        } label: {
                            Label("Excluir", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                    .menuIndicator(.hidden)
                }
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
            .navigationTitle("")
            
        }
        
    }
    
    private var contentView: some View {
        VStack {
            if let current {
                WorkspaceTitle(
                    workspace: current,
                    presenter: presenter
                )
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
        }
    }
    
    @ViewBuilder
    private func textEditorPanel(for route: WorkspaceDetailRoute) -> some View {
        switch route {
        case .newText:
            TextEditorSheet(
                mode: .create,
                onSave: { title, formattedText in
                    if let current {
                        Task {
                            await presenter.addArtefact(
                                to: current,
                                payload: .text(title: title, content: formattedText)
                            )
                            detailRoute = nil
                        }
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
        
        if let current {
            let workspaceToDelete = current
            
            let nextWorkspace = workspaces.first { $0.id != workspaceToDelete.id }
            
            if let nextWorkspace {
                selectedID = nextWorkspace.id
            } else {
                dismiss()
            }
            
            Task {
                await presenter.deleteWorkspace(workspaceToDelete)
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
