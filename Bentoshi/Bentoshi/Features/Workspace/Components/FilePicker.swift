//
//  FilePicker.swift
//  PocReferenciaArquivos
//
//  Created by Lizandra Malta on 15/06/26.
//

import SwiftUI

struct FilePicker: View {
    
    enum Mode {
        case create
        case edit(Artefact)
        
        var title: String {
            switch self {
            case .create:
                return "Adicionar arquivo"
                
            case .edit:
                return "Atualizar arquivo"
            }
        }
        
        var subtitle: String? {
            switch self {
            case .create:
                return nil
                
            case .edit:
                return "Escolha um novo arquivo para substituir a referência atual."
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
    }
    
    @State private var fileUrl: URL?
    @State private var isHovering = false
    @State private var fileName: String
    
    @Environment(\.dismiss) private var dismiss
    
    let mode: Mode
    var onSave: (_ fileUrl: URL, _ fileName: String) -> Void
    
    init(
        mode: Mode = .create,
        onSave: @escaping (_ fileUrl: URL, _ fileName: String) -> Void
    ) {
        self.mode = mode
        self.onSave = onSave
        _fileName = State(initialValue: mode.initialName)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            dropZone
            fileNameField
            footer
        }
        .padding(24)
        .frame(width: 520)
        .dragAndDropZone { (files: [URL]) in
            fileUrl = files.first
            
            if fileName.isEmpty, let fileUrl {
                fileName = fileUrl.lastPathComponent
            }
        } isHovering: { hovering in
            isHovering = hovering
        }
    }
}

private extension FilePicker {
    
    var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(mode.title)
                .font(.title2)
                .fontWeight(.semibold)
            
            if let subtitle = mode.subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    var dropZone: some View {
        VStack {
            if let fileUrl {
                selectedFileView(fileUrl)
            } else {
                emptyDropZoneView
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 260)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    Color.secondary.opacity(0.3)
                )
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    dropZoneStrokeColor,
                    style: StrokeStyle(
                        lineWidth:  2,
                        dash: [8]
                    )
                )
        }
        .animation(.easeInOut(duration: 0.2), value: isHovering)
    }
    
    var emptyDropZoneView: some View {
        VStack(spacing: 14) {
            Image(systemName: isHovering
                  ? "arrow.down.doc.fill"
                  : "tray.and.arrow.down.fill")
            .font(.system(size: 46))
            .foregroundStyle(dropZoneIconColor)
            
            Text(emptyDropZoneTitle)
                .font(.headline)
            
            Text("ou")
                .foregroundStyle(.secondary)
                .font(.caption)
            
            Button {
                openFinder()
            } label: {
                Label("Escolher arquivo", systemImage: "folder")
            }
            .buttonStyle(.borderedProminent)
            
            Text("Formatos suportados conforme o sistema")
                .foregroundStyle(.secondary)
                .font(.caption)
        }
    }
    
    func selectedFileView(_ fileUrl: URL) -> some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                
                Button {
                    withAnimation {
                        self.fileUrl = nil
                        fileName = mode.initialName
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            Image(systemName: "doc.fill")
                .font(.system(size: 54))
                .foregroundStyle(.blue)
            
            VStack(spacing: 4) {
                Text(fileUrl.lastPathComponent)
                    .font(.headline)
                
                Text("Arquivo selecionado")
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
    
    var fileNameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Nome do arquivo")
                .font(.headline)
            
            TextField("Digite um nome", text: $fileName)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    var footer: some View {
        HStack {
            Spacer()
            
            Button("Cancelar") {
                dismiss()
            }
            
            Button("Salvar") {
                saveFile()
            }
            .buttonStyle(.borderedProminent)
            .disabled(fileUrl == nil || fileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
    
    var dropZoneStrokeColor: Color {
        if isHovering {
            return .accentColor
        }
        
        return .secondary.opacity(0.2)
    }
    
    var dropZoneIconColor: Color {
        if isHovering {
            return .accentColor
        }
        
        return .secondary
    }
    
    var emptyDropZoneTitle: String {
        if isHovering {
            return "Solte o arquivo aqui"
        }
        
        return "Arraste seu arquivo para esta área"
    }
    
    func saveFile() {
        guard let fileUrl else { return }
        
        let trimmedName = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else { return }
        
        onSave(fileUrl, trimmedName)
        dismiss()
    }
    
    func openFinder() {
        let panel = NSOpenPanel()
        panel.title =  "Escolher arquivo"
        panel.prompt = "Escolher"
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK,
           let url = panel.url {
            fileUrl = url
            fileName = url.lastPathComponent
        }
    }
}

#Preview("Create") {
    FilePicker(mode: .create) { _, _ in }
}

#Preview("Edit") {
    FilePicker(
        mode: .edit(
            Artefact(
                name: "Contrato.pdf",
                type: .archive,
                content: "Contrato.pdf",
                workspaceId: UUID(),
                width: 100,
                height: 100,
                positionX: 0,
                positionY: 0
            )
        )
    ) { _, _ in }
}
