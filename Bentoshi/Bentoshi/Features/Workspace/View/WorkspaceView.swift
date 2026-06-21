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
    @State private var showFilePicker = false
    @State private var fileToUpdate: Artefact?
    @Binding var shouldReloadWorkspaces: Bool
    
    let workspace: Workspace
    
    private var allWorkspaces: [Workspace] {
        presenter.allWorkspaces
    }
    
    private var current: Workspace {
        allWorkspaces.first { $0.id == selectedID } ?? workspace
    }
    
    
    var body: some View {
        
        ZStack(alignment: .bottomTrailing){
            NavigationSplitView {
                
                List(allWorkspaces, selection: $selectedID) { ws in
                    Label(ws.name, systemImage: "square.grid.2x2")
                }
                .navigationTitle("Workspaces")
                
            } detail: {
                
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.adaptive(minimum: 160), spacing: 16)
                        ],
                        spacing: 16
                    ) {
                        ForEach(current.artefacts) { artefact in
                            ArtefactCard(artefact: artefact, pallete: current.coverColor) {
                                presenter.openArchive(artefact)
                            } onUpdate: {
                                if artefact.type == .archive {
                                    fileToUpdate = artefact
                                    showFilePicker = true
                                }
                            } onDelete: {
                                Task {
                                    await presenter.deleteArtefact(artefact, from: current)
                                }
                            }
                        }
                    }
                    .padding()
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
            
            FloatingAddButton(showFilePicker: $showFilePicker)
        }
        .onAppear {
            if selectedID == nil { selectedID = workspace.id }
        }
        .alert("Excluir workspace?", isPresented: $showDeleteConfirmation) {
            Button("Cancelar", role: .cancel) { }
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
        .sheet(isPresented: $showEditSheet) {
            EditWorkspaceView(workspace: current) { workspace, newName, newCoverColor in
                
                Task {
                    await presenter.updateWorkspace(workspace, newName: newName ?? workspace.name, newCoverColor: newCoverColor ?? workspace.coverColor )
                }
                
                shouldReloadWorkspaces = true
            }
        }
        .sheet(isPresented: $showFilePicker) {
            FilePicker { fileUrl, fileName in
                Task {
                    if let file = fileToUpdate {
                        await presenter.updateArchiveArtefact(file, newURL: fileUrl, newName: fileName)
                        
                        fileToUpdate = nil
                    } else {
                        await presenter.addFileArtefactType(at: current, archiveUrl: fileUrl, withName: fileName)
                    }
                }
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
