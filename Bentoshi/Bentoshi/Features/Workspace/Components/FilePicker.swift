//
//  FilePicker.swift
//  PocReferenciaArquivos
//
//  Created by Lizandra Malta on 15/06/26.
//

import SwiftUI
import UniformTypeIdentifiers

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
                return "Altere o nome ou escolha um novo arquivo para substituir a referência atual."
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
        
        var currentFileUrl: URL? {
            switch self {
            case .create:
                return nil
            case .edit(let artefact):
                return artefact.archiveUrl
            }
        }
        
        var initialKeywords: [String] {
            switch self {
            case .create:
                return []
            case .edit(let artefact):
                return artefact.getManualKeywords()
            }
        }
        
        var isEditing: Bool {
            if case .edit = self {
                return true
            }
            
            return false
        }
    }
    
    @State private var fileUrl: URL?
    @State private var isHovering = false
    @State private var fileName: String
    @State private var extractKeywords: [String]
    @State private var allKeywords = ""
    @State private var showKeywordsInfo = false
    
    @Environment(\.dismiss) private var dismiss
    
    let mode: Mode
    var onSave: (_ fileUrl: URL, _ fileName: String, _ extractKeywords: [String]) -> Void
    
    init(
        mode: Mode = .create,
        onSave: @escaping (_ fileUrl: URL, _ fileName: String, _ extractKeywords: [String]) -> Void
    ) {
        self.mode = mode
        self.onSave = onSave
        _fileName = State(initialValue: mode.initialName)
        _extractKeywords = State(initialValue: mode.initialKeywords)
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
    
    var selectedOrCurrentFileUrl: URL? {
        fileUrl ?? mode.currentFileUrl
    }
    
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
            } else if let currentUrl = mode.currentFileUrl {
                currentFileView(currentUrl)
            } else {
                emptyDropZoneView
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(.regularMaterial)
        .overlay {
            if isHovering || fileUrl != nil {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.blue, style: StrokeStyle(lineWidth: 2))
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.gray.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [8]))
            }
            
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    func currentFileView(_ fileUrl: URL) -> some View {
        VStack(spacing: 14) {
            FilePreview(url: fileUrl)
                .frame(width: 50, height: 60)

            Text(fileUrl.lastPathComponent)
                .font(.headline)
                .lineLimit(1)
       //         .padding(.bottom, 10)

            Text("\(fileType(for: fileUrl)) - \(fileSize(for: fileUrl))")
                .font(.body)
                .foregroundStyle(.secondary)
            
            Button {
                openFinder()
            } label: {
                Label("Substituir arquivo", systemImage: "folder")
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    var emptyDropZoneView: some View {
        VStack(spacing: 12) {
            Image(systemName: isHovering ? "arrow.down.doc.fill" : "tray.and.arrow.down.fill")
                .font(.system(size: 38))
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
        }
    }
    
    func selectedFileView(_ fileUrl: URL) -> some View {
        VStack(spacing: 4) {

            FilePreview(url: fileUrl)
                .frame(width: 50, height: 60)

            Text(fileUrl.lastPathComponent)
                .font(.headline)
                .lineLimit(1)
              //  .padding(.bottom, 10)

            Text("\(fileType(for: fileUrl)) - \(fileSize(for: fileUrl))")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
    
    var fileNameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Nome do arquivo")
                .foregroundStyle(.secondary)

            TextField("Digite um nome", text: $fileName)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    if canSave {
                        saveFile()
                    }
                }
            
            HStack {
                Text("Palavras chave (opcional)")
                    .foregroundStyle(.secondary)
                
                Button {
                    showKeywordsInfo.toggle()
                } label: {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showKeywordsInfo) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Separe as palavras‑chave utilizando uma vírgula comum.")
                    }
                    .padding()
                }
            }
            

            TextField("Palavra-chave 1, Palavra-chave 2, Palavra-chave 3", text: $allKeywords)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    commitPendingKeywords()
                }
            
            FlowLayout(spacing: 8) {
                ForEach(extractKeywords, id: \.self) { keyword in
                    HStack(spacing: 4){
                        Text(keyword)
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 10))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.gray.opacity(0.15))
                    .clipShape(Capsule())
                    .onTapGesture {
                        extractKeywords.removeAll { $0 == keyword }
                    }
                }
            }
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
            .disabled(!canSave)
        }
    }
    
    var canSave: Bool {
        let trimmedName = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty && selectedOrCurrentFileUrl != nil
    }
    
    var dropZoneStrokeColor: Color {
        isHovering ? .accentColor : .secondary.opacity(0.2)
    }
    
    var dropZoneIconColor: Color {
        isHovering ? .accentColor : .secondary
    }
    
    var emptyDropZoneTitle: String {
        isHovering ? "Solte o arquivo aqui" : "Arraste seu arquivo para esta área"
    }
    
    func saveFile() {
        let trimmedName = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let url = selectedOrCurrentFileUrl else { return }
        guard !trimmedName.isEmpty else { return }
        
        commitPendingKeywords()
        onSave(url, trimmedName, extractKeywords)
        dismiss()
    }
    
    func openFinder() {
        let panel = NSOpenPanel()
        panel.title = "Escolher arquivo"
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
    
    private func fileType(for url: URL) -> String {

        guard
            let type = UTType(filenameExtension: url.pathExtension)
        else {
            return url.pathExtension.uppercased()
        }

        return type.localizedDescription ?? url.pathExtension.uppercased()
    }
    
    private func fileSize(for url: URL) -> String {
        
        guard
            let values = try? url.resourceValues(forKeys: [.fileSizeKey]),
            let size = values.fileSize
        else {
            return ""
        }

        let formatter = ByteCountFormatter()
        formatter.countStyle = .file

        return formatter.string(fromByteCount: Int64(size))
    }
    
    func commitPendingKeywords() {
        let newKeywords = allKeywords
            .split(whereSeparator: { $0 == "," || $0 == ";" })
            .map { normalizeKeyword(String($0)) }
            .filter { !$0.isEmpty }

        guard !newKeywords.isEmpty else { return }

        addKeywords(newKeywords)

        allKeywords = ""
    }

    private func addKeywords(_ newKeywords: [String]) {
        var merged = Set(extractKeywords)
        merged.formUnion(newKeywords)

        extractKeywords = merged
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    private func normalizeKeyword(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
    }
}

#Preview("Create") {
    FilePicker(mode: .create) { _, _, _ in }
}
