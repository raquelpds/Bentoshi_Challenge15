//
//  WorkspaceDetailView.swift
//  WorkspaceBento
//
//  Created by Rebeca Maria de Morais Guimães on 16/06/26.
//

import SwiftUI

struct WorkspaceView: View {

    @Environment(\.dismiss) private var dismiss

    @State var presenter: WorkspacePresenter
    @State private var selectedID: Workspace.ID?
    @State private var showDeleteConfirmation = false
    @State private var showEditSheet = false
    @Binding var shouldReloadWorkspaces: Bool

    let workspace: Workspace
    
    private var allWorkspaces: [Workspace] {
        presenter.allWorkspaces
    }

    private var current: Workspace {
        allWorkspaces.first { $0.id == selectedID } ?? workspace
    }
    

    var body: some View {

        NavigationSplitView {

            List(allWorkspaces, selection: $selectedID) { ws in
                Label(ws.name, systemImage: "square.grid.2x2")
            }
            .navigationTitle("Workspaces")

        } detail: {

            ScrollView {
                Text(current.name)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(current.name)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showEditSheet = true
                        } label: {
                            Label("Editar", systemImage: "pencil")
                        }

                        Button(role: .destructive) {
                            showDeleteConfirmation = true
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
        .onAppear {
            if selectedID == nil { selectedID = workspace.id }
        }
        .alert("Excluir workspace?", isPresented: $showDeleteConfirmation) {
            Button("Cancelar", role: .cancel) { }
            //task para excluir
            Button("Excluir", role: .destructive) {
                Task {
                    await presenter.deleteWorkspace(current)
                    shouldReloadWorkspaces = true
                    dismiss()
                }
            }
        } message: {
            Text("Tem certeza que deseja excluir \"\(current.name)\"? Essa ação não pode ser desfeita.")
        }
        //sheet edicao
        .sheet(isPresented: $showEditSheet) {
            EditWorkspaceView(workspace: current) { workspace, newName, _ in

                guard let newName else { return }

                workspace.name = newName

                Task {
                    await presenter.updateWorkspace(workspace, newName: workspace.name)
                }
                
                shouldReloadWorkspaces = true
            }
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
