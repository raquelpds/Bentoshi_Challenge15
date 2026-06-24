//
//  WorkspaceFormSheet.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 20/06/26.
//

import SwiftUI

struct WorkspaceFormView: View {

    enum Mode {
        case create
        case edit(Workspace)

        var title: String {
            switch self {
            case .create:
                "Criar um Workspace"
            case .edit:
                "Editar o Workspace"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    let mode: Mode
    var onSave: (Workspace, String, WorkspaceColor) -> Void

    @State private var canSave = false
    @State private var workspaceName: String
    @State private var selectedColor: WorkspaceColor

    init(
        mode: Mode,
        onSave: @escaping (Workspace, String, WorkspaceColor) -> Void
    ) {
        self.mode = mode
        self.onSave = onSave

        switch mode {
        case .create:
            _workspaceName = State(initialValue: "")
            _selectedColor = State(initialValue: .gray)

        case .edit(let workspace):
            _workspaceName = State(initialValue: workspace.name)
            _selectedColor = State(initialValue: workspace.coverColor)
            _canSave = State(initialValue: true)
        }
    }

    var body: some View {
        VStack(spacing: 65) {
            
            VStack(spacing: 28) {
                VStack(spacing: 10) {
                    Text(mode.title)
                        .font(.headline)
                        .fontWeight(.semibold)

                    preview
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Nome")
                        .font(.subheadline)

                    TextField("Nome do workspace", text: $workspaceName)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color.gray.opacity(0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onChange(of: workspaceName) {
                            canSave = true
                        }
                    
                    WorkspaceColorSelector(selection: $selectedColor)
                }
            }

            HStack {
                Spacer()

                Button("Cancelar") {
                    dismiss()
                }

                Button("Salvar") {
                    save()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(!canSave)
            }
        }
        .padding(32)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding()
    }

    private var preview: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 18)
                .foregroundStyle(
                    ArtefactColorPalette.color(
                        for: .text,
                        workspaceBaseColor: selectedColor,
                        scheme: colorScheme
                    )
                )

            VStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 18)
                    .foregroundStyle(
                        ArtefactColorPalette.color(
                            for: .link,
                            workspaceBaseColor: selectedColor,
                            scheme: colorScheme
                        )
                    )
                    .frame(height: 78)

                RoundedRectangle(cornerRadius: 18)
                    .foregroundStyle(
                        ArtefactColorPalette.color(
                            for: .archive,
                            workspaceBaseColor: selectedColor,
                            scheme: colorScheme
                        )
                    )
            }
        }
        .frame(width: 240, height: 190)
        .onChange(of: workspaceName) { _, newValue in
            let trimmedName = newValue.trimmingCharacters(in: .whitespacesAndNewlines)

            if trimmedName.isEmpty {
                canSave = false
            }
        }
    }

    private func save() {
        let workspace: Workspace

        switch mode {
        case .create:
            workspace = Workspace(
                name: workspaceName,
                coverColor: selectedColor
            )

        case .edit(let existingWorkspace):
            workspace = existingWorkspace
        }

        onSave(workspace, workspaceName, selectedColor)
        dismiss()
    }
}

#Preview("Create") {
    WorkspaceFormView(mode: .create) { _, _, _ in
        //
    }
}

#Preview("Edit") {
    WorkspaceFormView(
        mode: .edit(
            Workspace(
                name: "iOS",
                coverColor: .blueDark
            )
        )
    ) { _, _, _ in
        //
    }
}
