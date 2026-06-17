//
//  BentoshiApp.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

import SwiftUI
import SwiftData

@main
struct BentoshiApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(for: [Workspace.self, Artefact.self, SearchIndex.self])
    }
}
