//
//  WorkspaceCard.swift
//  
//
//  Created by Rebeca Maria de Morais Guimães on 18/06/26.
//

import SwiftUI

struct WorkspaceCard: View {

    let workspaceName: String
    let color: Color

    var body: some View {
        VStack(spacing: 0) {
            color.opacity(0.3)

            HStack {
                Text(workspaceName)
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
    WorkspaceCard(workspaceName: "Workspace", color: .blue)
}
