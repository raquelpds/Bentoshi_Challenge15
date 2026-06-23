//
//  MenuBarFileView.swift
//  Bentoshi
//
//  Created by Ana Luisa Teixeira Coleone Reis on 23/06/26.
//

import SwiftUI

struct AddFileView: View {
    @State private var fileUrl: URL?
    @State private var isHovering = false
    @State private var fileName = ""
    
    let presenter: MenuBarPresenter
    let workspace: Workspace

    var body: some View {
        VStack(spacing: 24) {
            // Área de Drag & Drop
            VStack {
                if let file = fileUrl {

                    HStack {
                        Spacer()

                        Button {
                            self.fileUrl = nil
                            self.fileName = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer()

                    Image(systemName: "doc.fill")
                        .font(.system(size: 55))
                        .foregroundStyle(.blue)

                    Text(file.lastPathComponent)
                        .font(.headline)

                    Text("Arquivo selecionado")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                } else {
                    Spacer()

                    Image(systemName: "tray.and.arrow.down.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            isHovering ? .blue : .secondary
                        )

                    Text(
                        isHovering
                        ? "Solte o arquivo aqui"
                        : "Arraste seu arquivo para cá"
                    )
                    .font(.headline)

                    Text("ou selecione um arquivo")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()
                }
            }
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .background(.regularMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isHovering ? .blue : .gray.opacity(0.4),
                        style: StrokeStyle(
                            lineWidth: 2,
                            dash: [8]
                        )
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Nome do arquivo
            VStack(alignment: .leading, spacing: 8) {
                Text("Nome do arquivo")
                    .font(.headline)

                TextField(
                    "Digite um nome",
                    text: $fileName
                )
                .textFieldStyle(.roundedBorder)
            }

            // Botão
                Button {
                    Task {
                        guard let fileUrl = self.fileUrl else { return }

                        do {
                            await presenter.addArtefact(to: workspace, payload: .archive(url: fileUrl, name: fileName))
                            
                            self.fileName = ""
                            self.fileUrl = nil
                        } catch {
                            print(error)
                        }
                    }

                } label: {

                    Label(
                        "Adicionar ao Workspace",
                        systemImage: "plus.circle.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(fileUrl == nil || fileName.isEmpty)
            
        }
        .padding(24)
        .frame(width: 400)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .dropDestination(for: URL.self) { items, _ in

            self.fileUrl = items.first
            self.fileName = self.fileUrl?.lastPathComponent ?? ""

            return true

        } isTargeted: { hovering in

            isHovering = hovering

        }
    }
}
