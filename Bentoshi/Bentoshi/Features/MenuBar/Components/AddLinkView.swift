//
//  AddLinkView.swift
//  Bentoshi
//
//  Created by Ana Luisa Teixeira Coleone Reis on 23/06/26.
//

import SwiftUI

struct AddLinkView: View {

    @State private var isHovering = false
    @State private var newReceivedLink = ""
    @State private var newLinkName = ""

    let presenter: MenuBarPresenter
    let workspace: Workspace
    
    var body: some View {

        VStack(spacing: 24) {

            // Área principal
            VStack(spacing: 18) {
                
                HStack {
                    Spacer()

                    Button {
                        self.newReceivedLink = ""
                        self.newLinkName = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                Image(systemName: "link.circle.fill")
                    .font(.system(size: 55))
                    .foregroundStyle(
                        isHovering ? .blue : .secondary
                    )

                Text(
                    isHovering
                    ? "Solte o link aqui"
                    : "Arraste um link para cá"
                )
                .font(.headline)

                Text("ou adicione manualmente")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                VStack(spacing: 12) {

                    TextField(
                        "https://...",
                        text: $newReceivedLink
                    )
                    .textFieldStyle(.roundedBorder)

                    TextField(
                        "Adicione um nome ao seu link",
                        text: $newLinkName
                    )
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        Task {
                            if !newLinkName.isEmpty && !newReceivedLink.isEmpty {
                                await presenter.addArtefact(to: workspace, payload: .link(url: newReceivedLink, name: newLinkName))
                                newLinkName = ""
                                newReceivedLink = ""
                            }
                        }
                    }
                }

            }
            .padding()
            .frame(height: 250)
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

            // Botão
            Button {
                Task {
                    if !newLinkName.isEmpty && !newReceivedLink.isEmpty {
                        await presenter.addArtefact(to: workspace, payload: .link(url: newReceivedLink, name: newLinkName))
                        newLinkName = ""
                        newReceivedLink = ""
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
            .disabled(
                newReceivedLink.isEmpty ||
                newLinkName.isEmpty
            )

        }
        .padding(24)
        .frame(width: 400)
        .background(.regularMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )

        .dropDestination(for: URL.self) { items, _ in

            guard let url = items.first else {
                return false
            }

            newReceivedLink = url.absoluteString

            if newLinkName.isEmpty {
                newLinkName = url.host() ?? ""
            }

            return true

        } isTargeted: { hovering in

            isHovering = hovering

        }
    }
}
