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
    
    private var iconName: String {
        switch artefact.type {
        case .archive:
            return "doc"
        default:
            return "square.grid.2x2"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundStyle(.black)
                
                Text(artefact.name)
                    .font(.headline)
                    .foregroundStyle(.black)
                    .lineLimit(2)
                
                Text(artefact.type.rawValue)
                    .font(.caption)
                    .foregroundStyle(.black)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(
                width: artefact.width,
                height: artefact.height,
                alignment: .topLeading
            )
            .background(ArtefactColorPalette.color(for: artefact.type, workspaceBaseColor: pallete, scheme: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: 16))
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
