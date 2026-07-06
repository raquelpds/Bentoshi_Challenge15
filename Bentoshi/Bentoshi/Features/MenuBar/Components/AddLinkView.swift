//
//  AddLinkView.swift
//  Bentoshi
//
//  Created by Ana Luisa Teixeira Coleone Reis on 23/06/26.
//

import SwiftUI

struct AddLinkView: View {
    @State private var isHovering = false
    
    let presenter: MenuBarPresenter
    let workspaces: [Workspace]
    
    @Binding var selectedWorkspace: Workspace?
    @Binding var newReceivedLink: String
    @Binding var newLinkName: String
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Área de drop
            VStack(spacing: 14) {
                
                Image(systemName: newReceivedLink.isEmpty ? "link" : "link.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(isHovering || !newReceivedLink.isEmpty ? .blue : .secondary)
                
                if newReceivedLink.isEmpty {
                    Text(isHovering ? "Solte o link aqui" : "Arraste um link")
                        .font(.body)
                } else {
                    Text(newReceivedLink)
                        .font(.body)
                        .padding(.horizontal, 20)
                        .multilineTextAlignment(.center)
                }

            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(.regularMaterial)
            .overlay {
                if isHovering || !newReceivedLink.isEmpty {
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
                                .frame(width: 350)
                                .tag(workspace as Workspace?)
                               
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    
                    Spacer()
                }
                
                HStack {
                    Text("URL:")
                        .foregroundStyle(.secondary)
                        .frame(width: 90, alignment: .trailing)
                    
                    TextField("https://...", text: $newReceivedLink)
                        .textFieldStyle(.roundedBorder)
                        .controlSize(.large)
                    
                    Spacer()
                }
                
                HStack {
                    Text("Nome:")
                        .foregroundStyle(.secondary)
                        .frame(width: 90, alignment: .trailing)
                    
                    TextField("Adicione um nome ao seu link", text: $newLinkName)
                        .textFieldStyle(.roundedBorder)
                        .controlSize(.large)
                        .onSubmit {
                            Task {
                                guard
                                    let workspace = selectedWorkspace,
                                    !newReceivedLink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                                    !newLinkName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                else {
                                    return
                                }
                                
                                await presenter.addArtefact(
                                    to: workspace,
                                    payload: .link(
                                        url: newReceivedLink,
                                        name: newLinkName,
                                        keywords: []
                                    )
                                )
                                
                                newReceivedLink = ""
                                newLinkName = ""
                            }
                        }
                    
                    Spacer()
                }
            }
            
        }
        .padding(24)
        .frame(width: 400)
        .clipShape(RoundedRectangle(cornerRadius: 20))
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
