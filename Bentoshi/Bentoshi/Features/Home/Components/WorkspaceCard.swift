//
//  WorkspaceCard.swift
//  
//
//  Created by Rebeca Maria de Morais Guimães on 18/06/26.
//

import SwiftUI

struct WorkspaceCard: View {

    let workspace: Workspace
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            WorkspaceColorPalette.color(for: workspace.coverColor, scheme: colorScheme)

            HStack {
                Text(workspace.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.15))
        }
        .aspectRatio(453.0 / 314.0, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    WorkspaceCard(workspace: Workspace(name: "teste", coverColor: .blueDark))
}
