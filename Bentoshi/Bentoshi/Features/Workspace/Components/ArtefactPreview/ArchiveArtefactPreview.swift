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
        }
    }

    private var fallbackPreview: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.white)
    }
}
