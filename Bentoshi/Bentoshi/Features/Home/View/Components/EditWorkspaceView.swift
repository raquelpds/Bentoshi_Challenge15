//
//  EditWorkspaceView.swift
//  Bentoshi
//
//  Created by Rebeca Maria de Morais Guimães on 19/06/26.
//

import SwiftUI

struct EditWorkspaceView: View {

    let workspace: Workspace
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showError = false
    @State private var workspaceName: String
    @State private var selectedColor: Color
    
    
    init(
        workspace: Workspace,
        onSave: @escaping (Workspace, String?, Color?) -> Void
    ) {
        self.workspace = workspace
        self.onSave = onSave

        _workspaceName = State(initialValue: workspace.name)
        _selectedColor = State(initialValue: workspace.coverColor)
    }
    
    var onSave: (Workspace, String?, Color?) -> Void

    var body: some View {
        VStack(spacing: 20) {

            Text("Editar o Workspace")
                .font(.headline)
                .fontWeight(.semibold)

            Image("mockup")
                .resizable()
                .scaledToFit()
                .frame(height: 180)

            VStack(alignment: .leading, spacing: 6) {
                Text("Nome")
                    .font(.subheadline)

                TextField("Nome do workspace", text: $workspaceName)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color.gray.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onChange(of: workspaceName) { showError = false }

                if showError {
                    Text("Por favor, informe um nome para o workspace.")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            ColorPicker("Cor da capa", selection: $selectedColor)

            HStack(spacing: 12) {
                Button {
                    NSColorPanel.shared.close()
                    dismiss()
                } label: {
                    Text("Cancelar")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                }
                .buttonStyle(.plain)

                Button {
                        save()
                } label: {
                    Text("Salvar")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(32)
        .frame(maxWidth: 560)
        .background(Color.gray.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding()
    }
}

extension EditWorkspaceView {
    func save() {
        onSave(workspace, workspaceName, nil)
        
        NSColorPanel.shared.close()
        dismiss()
    }
}
