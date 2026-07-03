//
//  ArtefactCard.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 20/06/26.
//

import SwiftUI

struct ArtefactCard: View {

    let backgroundColor: Color
    let showsRevealInFinder: Bool
    let preview: ArtefactPreview

    let onOpen: () -> Void
    let onUpdate: () -> Void
    let onDelete: () -> Void
    let onRevealInFinder: () -> Void

    let onResizeChanged: (CGSize) -> Void
    let onResizeEnded: (CGSize) -> Void

    @State private var isHovering = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 15)
                .fill(backgroundColor)

            preview
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 15)
                )

            resizeHandle
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 15)
        )
        .overlay {
            if isHovering {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        .white.opacity(0.5),
                        lineWidth: 2
                    )
            }
        }
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovering = hovering
        }
        .onTapGesture {
            onOpen()
        }
        .contextMenu {
            Button("Abrir") {
                onOpen()
            }

            Button("Editar") {
                onUpdate()
            }

            if showsRevealInFinder {
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

    private var resizeHandle: some View {
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
                        onResizeChanged(value.translation)
                    }
                    .onEnded { value in
                        onResizeEnded(value.translation)
                    }
            )
    }
}
