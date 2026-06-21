//
//  WorkspaceDetailContent.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 20/06/26.
//

import SwiftUI

struct WorkspaceDetailContent: View {
    let workspace: Workspace
    let presenter: WorkspacePresenter
    @Binding var route: WorkspaceRoute?

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 160), spacing: 16)],
                spacing: 16
            ) {
                ForEach(workspace.artefacts) { artefact in
                    ArtefactCard(
                        artefact: artefact,
                        pallete: workspace.coverColor
                    ) {
                        presenter.open(artefact)
                    } onUpdate: {
                        route = .updateArchive(artefact)
                    } onDelete: {
                        Task {
                            await presenter.deleteArtefact(artefact, from: workspace)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(workspace.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        route = .editWorkspace
                    } label: {
                        Label("Editar", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        Task {
                            await presenter.deleteWorkspace(workspace)
                        }
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
}
