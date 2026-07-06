//
//  ArchiveArtefactPreview.swift
//  Bentoshi
//
//  Created by Raquel Souza on 01/07/26.
//

import SwiftUI
import AppKit

struct ArchiveArtefactPreview: View {

    let previewImage: NSImage?
    let fileName: String
    let backgroundColor: Color
    

    var body: some View {
        GeometryReader { geometry in
            archivePreview(
                width: geometry.size.width,
                height: geometry.size.height
            )
        }
    }

    @ViewBuilder
    private func archivePreview(
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        if let previewImage {
            Image(nsImage: previewImage)
                .resizable()
                .scaledToFill()
                .frame(
                    width: width,
                    height: height
                )
                .clipped()
                .allowsHitTesting(false)
        } else {
            fallbackPreview
                .frame(
                    width: width,
                    height: height
                )
        }
    }

    private var fallbackPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)

            VStack(spacing: 8) {
                Image(systemName: "folder.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(backgroundColor)

                Text(fileName)
                    .font(.body)
                    .foregroundStyle(backgroundColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }
        }
    }
}
