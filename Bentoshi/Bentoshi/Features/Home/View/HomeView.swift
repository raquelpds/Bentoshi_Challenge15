//
//  ContentView.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var workspaces: [Workspace]
    @Environment(\.modelContext) private var context
    
    @State var presenter: HomePresenter
    @State private var showWorkspaceForm = false
    @State private var showWorkspaceDeleteAlert = false
    @State private var workspaceToUpdate: Workspace?
    @State private var workspaceToDelete: Workspace?
    @State private var workspaceToNavigate: Workspace?
    
    private var workspaceResults: [Workspace] {
        presenter.searchedItems.compactMap(\.workspace)
    }
    
    private var artefactResults: [Artefact] {
        presenter.searchedItems.compactMap(\.artefact)
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Workspaces")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        SearchToolbarItem(
                            searchText: $presenter.searchText,
                            isExpanded: $presenter.isSearchBarExpanded
                        )
                    }
                }
                .navigationDestination(item: $workspaceToNavigate) { workspace in
                    WorkspaceBuilder.build(
                        context: context,
                        workspace: workspace
                    )
                }
                .onAppear {
                    if !presenter.searchText.isEmpty {
                        presenter.searchText = ""
                    }
                }
                .onChange(of: presenter.searchText) { _, _ in
                    presenter.onSearchTextChanged()
                }
                .sheet(isPresented: $showWorkspaceForm) {
                    WorkspaceFormView(mode: .create) { workspace, _, _ in
                        Task {
                            await presenter.addWorkspace(workspace)
                        }
                    }
                }
                .sheet(item: $workspaceToUpdate) { workspace in
                    WorkspaceFormView(mode: .edit(workspace)) { workspace, name, color in
                        Task {
                            await presenter.updateWorkspace(
                                workspace,
                                newName: name,
                                newCoverColor: color
                            )
                        }
                    }
                }
                .alert("Excluir workspace?", isPresented: $showWorkspaceDeleteAlert) {
                    Button("Excluir", role: .destructive) {
                        if let workspace = workspaceToDelete {
                            Task {
                                await presenter.deleteWorkspace(workspace)
                            }
                            
                            workspaceToDelete = nil
                        }
                    }
                    
                    Button("Cancelar", role: .cancel) {}
                } message: {
                    Text("Tem certeza que deseja excluir \"\(workspaceToDelete?.name ?? "")\"?")
                }
        }
    }
    
    private var content: some View {
        ZStack {
            workspaceGrid
                .opacity(isSearchActive ? 0 : 1)
                .allowsHitTesting(!isSearchActive)
            
            searchContent
                .opacity(isSearchActive ? 1 : 0)
                .allowsHitTesting(isSearchActive)
        }
    }
    
    private var isSearchActive: Bool {
        !presenter.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var workspaceGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                Button {
                    showWorkspaceForm = true
                } label: {
                    AddWorkspaceCard()
                }
                .buttonStyle(.plain)
                
                ForEach(workspaces) { workspace in
                    Button {
                        workspaceToNavigate = workspace
                    } label: {
                        WorkspaceCard(workspace: workspace)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button("Editar") {
                            workspaceToUpdate = workspace
                        }
                        
                        Divider()
                        
                        Button("Excluir", role: .destructive) {
                            workspaceToDelete = workspace
                            showWorkspaceDeleteAlert = true
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var searchContent: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                
                if presenter.isSearching {
                    HStack(spacing: 8) {
                        ProgressView()
                            .controlSize(.small)
                        
                        Text("Buscando...")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 16)
                }
                
                if !workspaceResults.isEmpty {
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(workspaceResults) { workspace in
                                Button {
                                    navigate(to: workspace)
                                } label: {
                                    WorkspaceCompactCard(workspace: workspace)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    if !artefactResults.isEmpty {
                        Divider()
                            .padding(.vertical)
                    }
                }
                
                if !artefactResults.isEmpty {
                    
                    Text("Artefatos")
                        .font(.headline)
                        .padding(.bottom, 8)
                    
                    ForEach(artefactResults) { artefact in
                        ArtefactSearchRow(artefact: artefact, showWorkspaceName: true){
                            presenter.open(artefact)
                        }
                        .padding(.vertical, 8)
                        .contextMenu {
                            Button("Abrir") {
                                presenter.open(artefact)
                            }
                            
                            Button("Mostrar Workspace") {
                                navigate(to: artefact.workspace)
                            }
                        }
                        
                        Divider()
                    }
                }
                
                if workspaceResults.isEmpty &&
                    artefactResults.isEmpty &&
                    !presenter.isSearching {
                    
                    emptySearchView
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                }
            }
            .padding()
        }
    }
    
    private var emptySearchView: some View {
        ContentUnavailableView(
            "Nada encontrado",
            systemImage: "magnifyingglass",
            description: Text("Tente buscar por outro termo.")
        )
    }
    
    private func navigate(to workspace: Workspace?) {
        workspaceToNavigate = workspace

        DispatchQueue.main.async {
            presenter.searchText = ""
        }
    }
}

#Preview {
    struct PreviewWithContextWrapper: View {
        @Environment(\.modelContext) private var context
        
        var body: some View {
            HomeBuilder.build(context: context)
        }
    }
    
    return PreviewWithContextWrapper()
}
