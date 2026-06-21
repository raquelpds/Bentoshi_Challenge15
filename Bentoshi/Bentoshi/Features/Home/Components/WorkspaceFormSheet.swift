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

    @State private var showError = false
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
        }
    }

    var body: some View {
        VStack(spacing: 20) {

            Text(mode.title)
                .font(.headline)
                .fontWeight(.semibold)

            preview

            VStack(alignment: .leading, spacing: 6) {
                Text("Nome")
                    .font(.subheadline)

                TextField("Nome do workspace", text: $workspaceName)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color.gray.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onChange(of: workspaceName) {
                        showError = false
                    }

                if showError {
                    Text("Por favor, informe um nome para o workspace.")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            WorkspaceColorSelector(selection: $selectedColor)

            HStack(spacing: 12) {
                Button {
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

    private var preview: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(
                    ArtefactColorPalette.color(
                        for: .text,
                        workspaceBaseColor: selectedColor,
                        scheme: colorScheme
                    )
                )

            VStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 24)
                    .foregroundStyle(
                        ArtefactColorPalette.color(
                            for: .link,
                            workspaceBaseColor: selectedColor,
                            scheme: colorScheme
                        )
                    )
                    .frame(height: 78)

                RoundedRectangle(cornerRadius: 24)
                    .foregroundStyle(
                        ArtefactColorPalette.color(
                            for: .archive,
                            workspaceBaseColor: selectedColor,
                            scheme: colorScheme
                        )
                    )
            }
        }
        .frame(width: 300, height: 240)
    }

    private func save() {
        let trimmedName = workspaceName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            showError = true
            return
        }

        let workspace: Workspace

        switch mode {
        case .create:
            workspace = Workspace(
                name: trimmedName,
                coverColor: selectedColor
            )

        case .edit(let existingWorkspace):
            workspace = existingWorkspace
        }

        onSave(workspace, trimmedName, selectedColor)
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
