//
//  AddWorkspaceCard.swift
//  
//
//  Created by Rebeca Maria de Morais Guimães on 18/06/26.
//

import SwiftUI

struct AddWorkspaceCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.gray.opacity(0.15))

            Image(systemName: "plus")
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(.black)
        }
        .aspectRatio(453.0 / 314.0, contentMode: .fit)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    AddWorkspaceCard()
}
