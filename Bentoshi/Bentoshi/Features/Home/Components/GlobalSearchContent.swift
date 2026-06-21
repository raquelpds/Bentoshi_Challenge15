//
//  WorkspaceSearchContent.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 21/06/26.
//

import SwiftUI

struct GlobalSearchContent: View {
    
    @Environment(\.modelContext) private var context
    
    @State private var workspaceToNavigate: Workspace?
    
    let presenter: HomePresenter
    
    private var workspaceResults: [Workspace] {
        presenter.searchedItems.compactMap(\.workspace)
    }
    
    private var artefactResults: [Artefact] {
        presenter.searchedItems.compactMap(\.artefact)
    }
    
    var body: some View {
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
        .navigationDestination(item: $workspaceToNavigate) { workspace in
            WorkspaceBuilder.build(
                context: context,
                workspace: workspace
            )
        }
    }
    
    private func navigate(to workspace: Workspace?) {
        workspaceToNavigate = workspace

        DispatchQueue.main.async {
            presenter.searchText = ""
        }
    }
    
    private var emptySearchView: some View {
        ContentUnavailableView(
            "Nada encontrado",
            systemImage: "magnifyingglass",
            description: Text("Tente buscar por outro termo.")
        )
    }
}
