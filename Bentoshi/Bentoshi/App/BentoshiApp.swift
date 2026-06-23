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
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(
                    for: Workspace.self,
                    Artefact.self,
                    SearchIndex.self
                )
            
            appDelegate.container = container
        } catch {
            fatalError("Error: \(error)")
        }
        
    }
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(container)
    }
}
