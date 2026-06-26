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
    
    // Estado para controlar se o mouse está em cima do card
    @State private var isHovering = false
    
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
                            ///modificador que serve para controlar se uma view pode ou não interagir com as ações do usuário
                            ///quando você renderiza certos tipos de arquivos ou páginas da web, o sistema injeta views nativas do sistema (como uma WKWebView para conteúdo web ou componentes do PDFKit
                            ///e isso estava atrapalhando o funcionamento do onHover.
                                .allowsHitTesting(false)
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
                // Fixa o retângulo cinza na base do frame
                .overlay(alignment: .bottom) {
                    if isHovering {
                        Color.black.opacity(0.4)
                            .frame(height: 48) 
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .clipped() // Corta os cantos do retângulo cinza no cornerRadius do card
                .contentShape(Rectangle()) // Força o reconhecimento de toda a área do grid
                .onHover { over in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHovering = over
                    }
                }
            }
        }
}
