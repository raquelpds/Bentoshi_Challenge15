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
    let backgroundColor: Color
    let textFormatted: NSAttributedString
    
    var body: some View {

        switch type {

        case .text:
            TextArtefactPreview(text: textFormatted)

        case .link:
            LinkArtefactPreview(name: name, url: content)

        case .archive:
            ArchiveArtefactPreview(previewImage: archivePreviewImage, fileName: name, backgroundColor: backgroundColor)
        }

    }
}

