//
//  TextArtefactPreview.swift
//  Bentoshi
//
//  Created by Raquel Souza on 01/07/26.
//

import SwiftUI

struct TextArtefactPreview: View {

    let text: String

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                
                Text(text)
                    .font(.body)
                    .foregroundStyle(.black)
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

