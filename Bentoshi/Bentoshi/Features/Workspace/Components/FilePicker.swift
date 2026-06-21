//
//  FilePicker.swift
//  PocReferenciaArquivos
//
//  Created by Lizandra Malta on 15/06/26.
//

import SwiftUI

struct FilePicker: View {

    @State private var fileUrl: URL?
    @State private var isHovering = false
    @State private var fileName = ""

    @Environment(\.dismiss) private var dismiss

    var onSave: (_ fileUrl: URL, _ fileName: String) -> Void

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
            fileName = fileUrl?.lastPathComponent ?? ""
            print(fileUrl?.path ?? "")
        } isHovering: { hovering in
            isHovering = hovering
        }
    }
}

private extension FilePicker {

    var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Adicionar arquivo")
                .font(.title2)
                .fontWeight(.semibold)
        }
    }

    var dropZone: some View {
        VStack {

            if let fileUrl {

                VStack(spacing: 16) {

                    HStack {
                        Spacer()

                        Button {
                            withAnimation {
                                self.fileUrl = nil
                                fileName = ""
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

            } else {

                VStack(spacing: 14) {
                    Image(systemName: isHovering
                          ? "arrow.down.doc.fill"
                          : "tray.and.arrow.down.fill")
                        .font(.system(size: 46))
                        .foregroundStyle(isHovering ? .blue : .secondary)

                    Text(isHovering
                         ? "Solte o arquivo aqui"
                         : "Arraste seu arquivo para esta área")
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
        }
        .frame(maxWidth: .infinity)
        .frame(height: 260)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.quaternary.opacity(0.3))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    isHovering
                    ? Color.accentColor
                    : Color.secondary.opacity(0.2),
                    style: StrokeStyle(
                        lineWidth: 2,
                        dash: [8]
                    )
                )
        }
        .animation(.easeInOut(duration: 0.2), value: isHovering)
    }

    var fileNameField: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("Nome do arquivo")
                .font(.headline)

            TextField(
                "Digite um nome",
                text: $fileName
            )
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
            .disabled(fileUrl == nil || fileName.isEmpty)
        }
    }

    func saveFile() {
        guard let fileUrl else { return }
        onSave(fileUrl, fileName)
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
}

#Preview {
    FilePicker { _,_  in }
}
