//
//  ArtefactCard.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 20/06/26.
//

import SwiftUI

struct ArtefactCard: View {

    @Environment(\.colorScheme) private var colorScheme

    let artefact: Artefact
    let pallete: WorkspaceColor

    let action: () -> Void
    let onUpdate: () -> Void
    let onDelete: () -> Void
    let onRevealInFinder: () -> Void

    let onResizeChanged: (CGSize) -> Void
    let onResizeEnded: (CGSize) -> Void
    
    @State private var isHovering = false

    var body: some View {

        ZStack(alignment: .bottomTrailing) {

            ArtefactPreview(
                   artefact: artefact,
                   palette: pallete
               )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

//               Text(artefact.name)
//                   .font(.headline)
//                   .foregroundStyle(.white)
//                   .lineLimit(2)
//                   .padding()

            Image(systemName: "arrow.down.right")
                .font(.caption)
                .foregroundStyle(.white)
                .padding(8)
                .background(.black)
                .clipShape(Circle())
                .padding(8)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            onResizeChanged(
                                value.translation
                            )
                        }
                        .onEnded { value in
                            onResizeEnded(
                                value.translation
                            )
                        }
                )
        }
        .onTapGesture {
            action()
        }
        .contextMenu {

            Button("Abrir") {
                action()
            }

            Button("Editar") {
                onUpdate()
            }

            if artefact.type == .archive {

                Button("Mostrar no Finder") {
                    onRevealInFinder()
                }
            }

            Divider()

            Button(
                "Excluir",
                role: .destructive
            ) {
                onDelete()
            }
        }
    }
}
