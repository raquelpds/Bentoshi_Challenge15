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
    @Binding var alert: WorkspaceAlert?

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
                        if artefact.checkIsMissingArchivePath() {
                            alert = .missingArchive(artefact)
                        } else {
                            presenter.open(artefact)
                        }
                    } onUpdate: {
                        route = .updateArchive(artefact)
                    } onDelete: {
                        alert = .deleteArtefact(artefact)
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
}
