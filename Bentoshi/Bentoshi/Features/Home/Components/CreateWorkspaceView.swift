//
//  CreateWorkspaceView.swift
//  
//
//  Created by Rebeca Maria de Morais Guimães on 18/06/26.
//

import SwiftUI

struct CreateWorkspaceView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showError = false
    @State private var workspaceName = ""
    @State private var selectedColor: WorkspaceColor = .gray
    
    var onSave: (Workspace, String?, WorkspaceColor?) -> Void

    var body: some View {
        VStack(spacing: 20) {

            Text("Criar um Workspace")
                .font(.headline)
                .fontWeight(.semibold)
   
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 24)
                    .foregroundStyle(
                        ArtefactColorPalette.color(
                            for: .text,
                            workspaceBaseColor: selectedColor,
                            scheme: colorScheme)
                    )
                VStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 24)
                        .foregroundStyle(
                            ArtefactColorPalette.color(
                                for: .link,
                                workspaceBaseColor: selectedColor,
                                scheme: colorScheme)
                        )
                        .frame(height: 78)
                    
                    RoundedRectangle(cornerRadius: 24)
                        .foregroundStyle(
                            ArtefactColorPalette.color(
                                for: .archive,
                                workspaceBaseColor: selectedColor,
                                scheme: colorScheme)
                        )
                }
      
            }
            .frame(width: 300, height: 240)

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

            WorkspaceColorSelector(selection: $selectedColor)
            
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

extension CreateWorkspaceView {
    
    func save() {
        let workspace = Workspace(name: workspaceName, coverColor: selectedColor)
        onSave(workspace, workspaceName, selectedColor)
        NSColorPanel.shared.close()
        dismiss()
    }
    
}

#Preview {
    CreateWorkspaceView(){_,_,_ in 
        //
    }
}
