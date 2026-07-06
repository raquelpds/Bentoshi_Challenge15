//
//  ArchivePreviewImageProvider.swift
//  Bentoshi
//
//  Created by Raquel Souza on 03/07/26.
//

import AppKit
import Foundation
import UniformTypeIdentifiers

struct ArchivePreviewImageProvider {

    func previewImage(for artefact: Artefact) -> NSImage? {
        guard artefact.type == .archive else {
            return nil
        }

        guard let url = artefact.archiveUrl else {
            return nil
        }

        guard isImageFile(url) else {
            return nil
        }

        let didAccess = url.startAccessingSecurityScopedResource()

        defer {
            if didAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        return NSImage(contentsOf: url)
    }

    private func isImageFile(_ url: URL) -> Bool {
        guard let type = UTType(filenameExtension: url.pathExtension) else {
            return false
        }

        return type.conforms(to: .image)
    }
}
