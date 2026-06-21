//
//  WorkspaceCard.swift
//  
//
//  Created by Rebeca Maria de Morais Guimães on 18/06/26.
//

import SwiftUI

struct WorkspaceCompactCard: View {

    let workspace: Workspace
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            WorkspaceColorPalette.color(for: workspace.coverColor, scheme: colorScheme)

            Text(workspace.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Color.gray.opacity(0.15))
        }
        .frame(width: 160, height: 110)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    WorkspaceCompactCard(workspace: Workspace(name: "teste", coverColor: .blueDark))
}
