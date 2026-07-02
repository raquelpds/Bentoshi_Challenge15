//
//  ArtefactPreview.swift
//  Bentoshi
//
//  Created by Raquel Souza on 02/07/26.
//

import SwiftUI

struct ArtefactPreview: View {
    
    @Environment(\.colorScheme)
    private var colorScheme
    
    let artefact: Artefact
    let palette: WorkspaceColor
    
    @State private var isHovering = false
    
    var body: some View {
        GeometryReader { geometry in
            let cardWidth = geometry.size.width
            let cardHeight = geometry.size.height
            
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(backgroundColor)
                        .shadow(radius: 4)
                    
                    previewContent(
                        width: cardWidth,
                        height: cardHeight
                    )
                }
                .cornerRadius(15)
                .overlay(alignment: .bottom) {
                    if isHovering {
                        ZStack(alignment: .leading) {
                            Color.black.opacity(0.4)
                                .frame(height: 48)

                            Text(artefact.name)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .lineLimit(2)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .clipped()
                .contentShape(Rectangle())
                .onHover { over in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHovering = over
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func previewContent(width: CGFloat, height: CGFloat) -> some View {
        switch artefact.type {
        case .text:
            textPreview(width: width, height: height)
            
        case .archive:
            archivePreview(width: width, height: height)
            
        case .link:
            fallbackPreview
        }
    }
    
    private func textPreview(width: CGFloat, height: CGFloat) -> some View {
        Text(artefact.content)
            .font(.system(size: 14, weight: .regular))
            .foregroundStyle(.primary)
            .multilineTextAlignment(.leading)
            .lineLimit(maxTextLines(for: height))
            .truncationMode(.tail)
            .padding(16)
            .frame(
                width: width,
                height: height,
                alignment: .topLeading
            )
    }
    
    @ViewBuilder
    private func archivePreview(width: CGFloat, height: CGFloat) -> some View {
        if let image = artefact.previewImage {
            Image(nsImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .allowsHitTesting(false)
        } else {
            fallbackPreview
        }
    }
    
    private var fallbackPreview: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(backgroundColor)
    }
    
    private func maxTextLines(for height: CGFloat) -> Int {
        let verticalPadding: CGFloat = 32
        let lineHeight: CGFloat = 18
        
        return max(1, Int((height - verticalPadding) / lineHeight))
    }
    
    private var backgroundColor: Color {
        ArtefactColorPalette.color(
            for: artefact.type,
            workspaceBaseColor: palette,
            scheme: colorScheme
        )
    }
}
