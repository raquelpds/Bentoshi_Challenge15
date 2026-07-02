//
//  WorkspaceColorSelector.swift
//  Bentoshi
//
//  Created by Rebeca Maria de Morais Guimães on 19/06/26.
//

import SwiftUI

struct WorkspaceColorSelector: View {

    @Binding var selection: WorkspaceColor
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Cor")
                .font(.subheadline)

            HStack(spacing: 10){
                ForEach(WorkspaceColor.allCases, id: \.self) { color in
                    Group {
                        if selection != color {
                            Capsule()
                                .fill(WorkspaceColorPalette.color(for: color, scheme: colorScheme))
                        }
                        else {
                            ZStack {
                                Capsule()
                                    .stroke(WorkspaceColorPalette.color(for: color, scheme: colorScheme),
                                            lineWidth: 3)
                                Capsule()
                                    .fill(WorkspaceColorPalette.color(for: color, scheme: colorScheme))
                                    .frame(width: 48, height: 15)
                            }
                        }
                    }
                    .frame(width: 60, height: 25)
                    .onTapGesture {
                        selection = color
                    }
                }
            }
        }
    }
}
