//
//  MenuBarFileView.swift
//  Bentoshi
//
//  Created by Ana Luisa Teixeira Coleone Reis on 23/06/26.
//

import SwiftUI
import QuickLookThumbnailing
import UniformTypeIdentifiers

struct AddFileView: View {

    @State private var isHovering = false

    let presenter: MenuBarPresenter
    let workspaces: [Workspace]

    @Binding var selectedWorkspace: Workspace?
    @Binding var newFileUrl: URL?
    @Binding var newFileName: String

    var body: some View {
        VStack(spacing: 20) {

            // Área de drag & drop
            VStack(spacing: 14) {

                if let file = newFileUrl {

                    VStack(spacing: 4) {

                        FilePreview(url: file)
                            .frame(width: 50, height: 60)

                        Text(file.lastPathComponent)
                            .font(.headline)
                            .lineLimit(1)
                            .padding(.bottom, 20)

                        Text("\(fileType(for: file)) - \(fileSize(for: file))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                } else {

                    Image(systemName: "tray.and.arrow.down.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(isHovering || newFileUrl != nil ? .blue : .secondary)

                    Text(isHovering ? "Solte o arquivo aqui" : "Arraste um arquivo")
                        .font(.title3)
                        .fontWeight(.medium)
                }

            }
            .frame(maxWidth: .infinity)
            .frame(height: newFileUrl != nil ? 200 : 140)
            .background(.regularMaterial)
            .overlay {
                if isHovering || newFileUrl != nil {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.blue, style: StrokeStyle(lineWidth: 2))
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.gray.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [8]))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(spacing: 14) {

                HStack {
                    Text("Workspace:")
                        .foregroundStyle(.secondary)
                        .frame(width: 90, alignment: .trailing)

                    Picker("", selection: $selectedWorkspace) {
                        ForEach(workspaces) { workspace in
                            Text(workspace.name)
                                .tag(workspace as Workspace?)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)

                    Spacer()
                }

                HStack {
                    Text("Nome:")
                        .foregroundStyle(.secondary)
                        .frame(width: 90, alignment: .trailing)

                    TextField("Digite um nome", text: $newFileName)
                        .textFieldStyle(.roundedBorder)
                        .controlSize(.large)

                    Spacer()
                }
            }

        }
        .padding(24)
        .frame(width: 400)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .dropDestination(for: URL.self) { items, _ in

            guard let file = items.first else {
                return false
            }

            newFileUrl = file
            newFileName = file.lastPathComponent

            return true

        } isTargeted: { hovering in
            isHovering = hovering
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
}



struct FilePreview: View {

    let url: URL

    @State private var image: NSImage?

    var body: some View {
        Group {
            if let image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
            }
        }
        .task {
            await loadThumbnail()
        }
    }

    @MainActor
    private func loadThumbnail() async {

        let request = QLThumbnailGenerator.Request(
            fileAt: url,
            size: CGSize(width: 180, height: 180),
            scale: NSScreen.main?.backingScaleFactor ?? 2,
            representationTypes: .thumbnail
        )

        do {
            let thumbnail = try await QLThumbnailGenerator.shared.generateBestRepresentation(for: request)
            image = thumbnail.nsImage
        } catch {
            print(error)
        }
    }
}
