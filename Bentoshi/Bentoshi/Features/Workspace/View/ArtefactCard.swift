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

        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(ArtefactColorPalette.color(
                    for: artefact.type,
                    workspaceBaseColor: pallete,
                    scheme: colorScheme)
                    )
            
            preview
        }

        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay {
            if isHovering {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(.white.opacity(0.5), lineWidth: 2)
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged {
                    onResizeChanged($0.translation)
                }
                .onEnded {
                    onResizeEnded($0.translation)
                }
        )
        .onHover {
            isHovering = $0
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

            Button("Excluir", role: .destructive) {
                onDelete()
            }

        }

    }

}
