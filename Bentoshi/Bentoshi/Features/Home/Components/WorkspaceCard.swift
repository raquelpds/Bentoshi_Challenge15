//
//  WorkspaceCard.swift
//  
//
//  Created by Rebeca Maria de Morais Guimães on 18/06/26.
//

import SwiftUI

struct WorkspaceCard: View {

    @Environment(\.colorScheme) private var colorScheme
    let workspace: Workspace
    let sortOption: SortOption
    
    var body: some View {
        VStack(spacing: 0) {
            WorkspaceColorPalette.color(for: workspace.coverColor, scheme: colorScheme)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(workspace.name)
                        .font(.headline)
                        .fontWeight(.semibold)

                    Spacer()
                }

                Text(dateText)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.15))
        }
        .aspectRatio(453.0 / 314.0, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    private var dateText: String {
        let isCreatedSort = sortOption == .lastCreated

        let prefix = isCreatedSort ? "Criado" : "Modificado"
        let date = isCreatedSort ? workspace.createdAt : workspace.updatedAt

        if Calendar.current.isDateInToday(date) {
            return "\(prefix) hoje"
        }

        if Calendar.current.isDateInYesterday(date) {
            return "\(prefix) ontem"
        }

        return "\(prefix) em: \(date.formatted(.dateTime.day().month().year()))"
    }

}

#Preview("Sort Alphabet") {
    WorkspaceCard(workspace: Workspace(name: "teste", coverColor: .blueDark), sortOption: .alphabet)
}

#Preview("Sort Last Modified") {
    WorkspaceCard(workspace: Workspace(name: "teste", coverColor: .blueDark), sortOption: .lastModified)
}

#Preview("Sort Last Created") {
    WorkspaceCard(workspace: Workspace(name: "teste", coverColor: .blueDark), sortOption: .lastCreated)
}
