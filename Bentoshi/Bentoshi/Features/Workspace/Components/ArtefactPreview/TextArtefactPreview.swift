//
//  TextArtefactPreview.swift
//  Bentoshi
//
//  Created by Raquel Souza on 01/07/26.
//

import SwiftUI


struct TextArtefactPreview: View {

    let title: String
    let text: String

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Image(systemName: "text.alignleft")
                .font(.title2)

            Spacer()

            Text(title)
                .font(.headline)
                .lineLimit(2)

            Text(text)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineLimit(4)
        }
        .padding()
    }
}
