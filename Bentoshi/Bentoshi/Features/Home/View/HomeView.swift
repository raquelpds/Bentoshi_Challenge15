//
//  ContentView.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

import SwiftUI

struct HomeView: View {
    
    @State var presenter: HomePresenter
    @State private var showWorkspaceForm = false
    @State private var showWorkspaceDeleteAlert = false
    @State private var shouldReloadWorkspaces = false
    @State private var workspaceToUpdate: Workspace?
    @State private var workspaceToDelete: Workspace?
    @Environment(\.modelContext) private var context
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        
        NavigationStack {
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    
                    Button {
                        showWorkspaceForm = true
                    } label: {
                        AddWorkspaceCard()
                    }
                    .buttonStyle(.plain)
                    
                    ForEach(presenter.workspaces) { workspace in
                        NavigationLink {
                            WorkspaceBuilder.build(context: context, workspace: workspace, shouldReloadWorkspace: $shouldReloadWorkspaces)
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
            .navigationTitle("Workspaces")
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
            Text(
                "Tem certeza que deseja excluir \"\(workspaceToDelete?.name ?? "")\"?"
            )
        }
        .task {
            await presenter.listWorkspaces()
        }
        .onChange(of: shouldReloadWorkspaces) { oldValue, newValue in
            if (shouldReloadWorkspaces) {
                Task {
                    await presenter.listWorkspaces()
                }
                shouldReloadWorkspaces = false
            }
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
