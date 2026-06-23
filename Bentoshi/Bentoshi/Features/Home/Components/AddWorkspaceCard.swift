//
//  AddWorkspaceCard.swift
//  
//
//  Created by Rebeca Maria de Morais Guimães on 18/06/26.
//

import SwiftUI

struct AddWorkspaceCard: View {
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 35)
                    .fill(Color.neutralColor1)

                Image(systemName: "plus")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(.black)
            }
            .frame(height: 230)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)

    }
}

#Preview {
    AddWorkspaceCard()
}
