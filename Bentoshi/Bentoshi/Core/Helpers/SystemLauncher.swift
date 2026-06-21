//
//  ArtefactOpener.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 21/06/26.
//

import AppKit

enum SystemLauncher {

    static func revealInFinder(_ url: URL) {
        let accessing = url.startAccessingSecurityScopedResource()

        defer {
            if accessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    static func open(_ url: URL) {

        guard url.isFileURL else {
            NSWorkspace.shared.open(url)
            return
        }

        let accessing = url.startAccessingSecurityScopedResource()

        defer {
            if accessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        NSWorkspace.shared.open(url)
    }
}
