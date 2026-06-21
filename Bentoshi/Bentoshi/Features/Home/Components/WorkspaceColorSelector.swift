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

//    private let columns = [GridItem(.adaptive(minimum: 44), spacing: 12)]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Cor")
                .font(.subheadline)

            HStack( spacing: 6){
                ForEach(WorkspaceColor.allCases, id: \.self) { color in
                    Capsule()
                        .fill(WorkspaceColorPalette.color(for: color, scheme: colorScheme))
                        .frame(width: 40, height: 20)
                        .overlay {
                            Capsule()
                                .stroke(Color.primary, lineWidth: selection == color ? 2 : 0)
                        }
                        .onTapGesture {
                            selection = color
                        }
                }
            }
        }
    }
}
