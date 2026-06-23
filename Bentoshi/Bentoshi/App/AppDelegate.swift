//
//  AppDelegate.swift
//  
//
//  Created by Ana Luisa Teixeira Coleone Reis on 23/06/26.
//

import AppKit
import SwiftUI
import SwiftData

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var window: NSWindow?
    var container: ModelContainer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Cria o ícone na Menu Bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "star", accessibilityDescription: "Menu")
            // Define a ação do clique no ícone
            button.action = #selector(toggleMenuBarWindow)
            button.target = self
        }
        
        guard let container else {
            fatalError()
        }
        
        // Configura a Janela que vai aparecer
        let hostingController = NSHostingController(
            rootView: MenuBarView()
                .modelContainer(container)
        )
        
        window = NSWindow(contentViewController: hostingController)
        window?.styleMask = [.titled, .fullSizeContentView]
        window?.titleVisibility = .hidden
        window?.titlebarAppearsTransparent = true
        window?.isMovableByWindowBackground = false
        window?.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window?.standardWindowButton(.zoomButton)?.isHidden = true
        window?.level = .statusBar        // Garante que fica por cima de tudo
        window?.isReleasedWhenClosed = false
        window?.hidesOnDeactivate = false // Impede de fechar ao clicar fora
    }

    @objc func toggleMenuBarWindow() {
        guard let window = window, let button = statusItem?.button else { return }

        if window.isVisible {
            // Se já está aberta, fecha
            window.orderOut(nil)
        } else {
            // Se está fechada, calcula a posição exata logo abaixo do ícone da Menu Bar
            let buttonFrame = button.window?.frame ?? .zero
            let windowFrame = window.frame
            
            let xPosition = buttonFrame.origin.x + (buttonFrame.width / 2) - (windowFrame.width / 2)
            let yPosition = buttonFrame.origin.y - windowFrame.height
            
            window.setFrameOrigin(NSPoint(x: xPosition, y: yPosition))
            
            // Mostra a janela e traz para a frente sem roubar o foco do teclado de outros apps obrigatoriamente
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}



