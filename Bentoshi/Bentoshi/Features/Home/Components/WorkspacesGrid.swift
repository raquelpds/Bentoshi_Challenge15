//
//  WorkspacesGrid.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 21/06/26.
//

import SwiftUI
import SwiftData

struct WorkspacesGrid: View {
    
    @Query private var workspaces: [Workspace]
    @Environment(\.modelContext) private var context
    
    @State private var showWorkspaceForm = false
    @State private var showWorkspaceDeleteAlert = false
    @State private var workspaceToUpdate: Workspace?
    @State private var workspaceToDelete: Workspace?
    @State private var workspaceToNavigate: Workspace?
    
    let presenter: HomePresenter
    
    var body: some View {
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
        .navigationDestination(item: $workspaceToNavigate) { workspace in
            WorkspaceBuilder.build(
                context: context,
                workspace: workspace
            )
        }
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
}
