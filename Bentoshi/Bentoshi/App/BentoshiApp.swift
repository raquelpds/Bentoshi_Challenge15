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
    let larguraTela = NSScreen.main?.visibleFrame.width ?? 1440
    
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
        //tamanho inicial ao abrir
        .defaultSize(width: larguraTela * 0.9, height: 900)
        .modelContainer(container)
    }
}
