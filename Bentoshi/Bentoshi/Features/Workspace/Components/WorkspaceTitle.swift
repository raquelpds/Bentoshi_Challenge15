//
//  WorkspaceTitle.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 26/06/26.
//

import SwiftUI

struct WorkspaceTitle: View {
    
    @State private var name: String
    @State private var previousName: String
    @State private var isEditing = false
    
    @FocusState private var isFocused: Bool
    
    let workspace: Workspace
    let presenter: WorkspacePresenter
    
    init(workspace: Workspace, presenter: WorkspacePresenter) {
        _name = State(initialValue: workspace.name)
        _previousName = State(initialValue: workspace.name)
        self.workspace = workspace
        self.presenter = presenter
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image("BIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 32)
            
            if isEditing {
                TextField("", text: $name)
                    .font(.largeTitle)
                    .fontDesign(.rounded)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .onSubmit {
                        finishEditing()
                    }
                    .onChange(of: isFocused) { _, focused in
                        if !focused {
                            finishEditing()
                        }
                    }
            } else {
                Text(name)
                    .font(.largeTitle)
                    .fontDesign(.rounded)
                    .onTapGesture {
                        isEditing = true
                        isFocused = true
                    }
                    .multilineTextAlignment(.leading)
                
            }
            Spacer()
        }
        .padding(24)
    }
    
    @MainActor
    private func finishEditing() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            name = previousName
            isEditing = false
            return
        }
        
        name = trimmedName
        isEditing = false
        
        guard trimmedName != previousName else {
            return
        }
        
        previousName = trimmedName
        
        Task {
            await presenter.updateWorkspaceName(
                workspace,
                newName: trimmedName
            )
        }
    }
}
