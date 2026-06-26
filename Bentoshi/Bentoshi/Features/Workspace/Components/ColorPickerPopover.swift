//
//  ColorPickerPopover.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 25/06/26.
//

import SwiftUI

struct ColorPickerPopover: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @State var colorPicked: WorkspaceColor = .gray
    let workspace: Workspace
    let presenter: WorkspacePresenter
    
    init(workspace: Workspace, presenter: WorkspacePresenter) {
        _colorPicked = State(initialValue: workspace.coverColor)
        self.workspace = workspace
        self.presenter = presenter
    }
    
    var body: some View {
        VStack(spacing: 16) {
            
            Text("Cor")
            
            HStack(spacing: 5) {
                ForEach(WorkspaceColor.allCases, id: \.self) { color in
                    Group {
                        if colorPicked != color {
                            Capsule()
                                .fill(WorkspaceColorPalette.color(for: color, scheme: colorScheme))
                        }
                        else {
                            ZStack {
                                Capsule()
                                    .stroke(WorkspaceColorPalette.color(for: color, scheme: colorScheme),
                                            lineWidth: 1)
                                Capsule()
                                    .fill(WorkspaceColorPalette.color(for: color, scheme: colorScheme))
                                    .frame(width: 21, height: 7)
                            }
                        }
                    }
                    .frame(width: 27, height: 11)
                    .onTapGesture {
                        colorPicked = color
                    }
                }
            }
        }
        .onChange(of: colorPicked) { _, newValue in
            Task {
                await presenter.updateWorkspaceCoverColor(workspace, newCoverColor: newValue)
            }
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 16)
        .padding(.top, 10)
    }
}
