//
//  WorkspaceSearchContent.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 21/06/26.
//

import SwiftUI

struct WorkspaceSearchContent: View {

    let workspace: Workspace
    @Bindable var presenter: WorkspacePresenter

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

                if !artefactResults.isEmpty {
                    ForEach(artefactResults) { artefact in
                        ArtefactSearchRow(artefact: artefact) {
                            presenter.open(artefact)
                        }
                        Divider()
                    }
                }

                if artefactResults.isEmpty && !presenter.isSearching {
                    ContentUnavailableView(
                        "Nada encontrado",
                        systemImage: "magnifyingglass",
                        description: Text("Tente buscar por outro termo.")
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                }
            }
            .padding()
        }
    }
}
