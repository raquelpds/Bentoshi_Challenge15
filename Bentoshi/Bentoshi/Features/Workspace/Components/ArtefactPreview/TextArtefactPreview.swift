//
//  TextArtefactPreview.swift
//  Bentoshi
//
//  Created by Raquel Souza on 01/07/26.
//

import SwiftUI

struct TextArtefactPreview: View {
    
    let text: NSAttributedString
    @State private var selectedRange: NSRange = .init(location: 0, length: 0)
    @StateObject private var editorContext = TextEditorContext()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                
                RichTextViewer(
                    text: text,
                )
                .multilineTextAlignment(.leading)
                .lineLimit(maxTextLines(for: geometry.size.height))
                .truncationMode(.tail)
                .padding(16)
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height,
                    alignment: .topLeading
                )
                
            }
        }
    }
    
    private func maxTextLines(
        for height: CGFloat
    ) -> Int {
        let verticalPadding: CGFloat = 32
        let lineHeight: CGFloat = 18
        
        return max(
            1,
            Int((height - verticalPadding) / lineHeight)
        )
    }
}

