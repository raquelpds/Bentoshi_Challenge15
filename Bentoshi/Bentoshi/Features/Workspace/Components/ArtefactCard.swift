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
    
//    
//    private let cellSize: CGFloat = 60
//    
//    //variaveis para o drag and drop
//    @State private var dragOffset: CGSize = .zero
    
    
    var body: some View {
        //manter que todos são um botão
        Button(action: action) {
            
            ZStack(alignment: .center) {
                
                RoundedRectangle(cornerRadius: 15)
                    .fill(ArtefactColorPalette.color(for: artefact.type, workspaceBaseColor: pallete, scheme: colorScheme))
                
                Text(artefact.name)
                    .font(.headline)
                    .foregroundStyle(.black)
                    .lineLimit(2)
            }
//            .frame(width: CGFloat(artefact.width) * cellSize, height: CGFloat(artefact.height) * cellSize)
//            .position(
//                x: CGFloat(artefact.column) * cellSize + CGFloat(artefact.width) * cellSize / 2 + dragOffset.width,
//                y: CGFloat(artefact.row) * cellSize + CGFloat(artefact.height) * cellSize / 2 + dragOffset.height
//            )
//            .gesture(
//                DragGesture()
//                    .onChanged {
//                        dragOffset = $0.translation
//                    }
//                    .onEnded { _ in
//                        dragOffset = .zero
//                    }
//            )
        }
        
        .buttonStyle(.plain)
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
