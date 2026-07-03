//
//  ArtefactPreview.swift
//  Bentoshi
//
//  Created by Raquel Souza on 25/06/26.
//

import SwiftUI
import AppKit


struct ArtefactPreview: View {

    let type: ArtefactType
    let name: String
    let content: String
    let archivePreviewImage: NSImage?

    var body: some View {

        switch type {

        case .text:
            TextArtefactPreview(text: content)

        case .link:
            LinkArtefactPreview(name: name, url: content)

        case .archive:
            ArchiveArtefactPreview(previewImage: archivePreviewImage)
        }

    }
}

