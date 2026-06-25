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
