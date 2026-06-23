//
//  LinkForm.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 23/06/26.
//

import SwiftUI

struct LinkFormSheet: View {
    
    enum Mode {
        case create
        case edit(Artefact)

        var title: String {
            switch self {
            case .create:
                "Adicionar link"
            case .edit:
                "Editar link"
            }
        }
        
        var initialName: String {
            switch self {
            case .create:
                return ""
            case .edit(let artefact):
                return artefact.name
            }
        }
        
        var initialUrl: String {
            switch self {
            case .create:
                return ""
            case .edit(let artefact):
                return artefact.content
            }
        }
    }
    
    @State private var url: String
    @State private var name: String
    @Environment(\.dismiss) private var dismiss
    
    let mode: Mode
    var onSave: (_ url: String, _ name: String) -> Void
    
    init(
        mode: Mode = .create,
        onSave: @escaping (_ url: String, _ name: String) -> Void
    ) {
        self.mode = mode
        self.onSave = onSave
        _name = State(initialValue: mode.initialName)
        _url = State(initialValue: mode.initialUrl)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(mode.title)
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("Link:")
                TextField("", text: $url)
            }
            
            HStack(spacing: 4) {
                Text("Aparecer como:")
                TextField("", text: $name)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button("Cancelar") {
                    dismiss()
                }
                
                Button("Salvar") {
                    onSave(url, name)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canSave)
            }
        }
        .padding()
    }
    
    var canSave: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedUrl = url.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty && !trimmedUrl.isEmpty
    }
}
