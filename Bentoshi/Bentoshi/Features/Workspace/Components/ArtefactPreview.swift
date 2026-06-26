//
//  ArtefactPreview.swift
//  Bentoshi
//
//  Created by Raquel Souza on 25/06/26.
//

import SwiftUI
import AppKit

struct ArtefactPreview: View {
    
    @Environment(\.colorScheme)
    private var colorScheme
    
    let artefact: Artefact
    let palette: WorkspaceColor
    
    let cellSize: CGFloat = 60
    
    var body: some View {
        
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .shadow(radius: 4)
                
                Group {
                    if let image = artefact.previewImage {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        RoundedRectangle(cornerRadius: 15)
                                .fill(
                                    ArtefactColorPalette.color(
                                        for: artefact.type,
                                        workspaceBaseColor: palette,
                                        scheme: colorScheme
                                    )
                                )
                    }
                }
            }
            .frame(width: CGFloat(artefact.width) * cellSize, height: CGFloat(artefact.height) * cellSize)
            .cornerRadius(15)
            // IMPEDE A IMAGEM DE VAZAR: Corta qualquer conteúdo que passe do frame acima
            .clipped()
//            .overlay(
//                RoundedRectangle(cornerRadius: 8)
//                    .stroke(Color.black, lineWidth: 1)
//            )
        }
    }
}
