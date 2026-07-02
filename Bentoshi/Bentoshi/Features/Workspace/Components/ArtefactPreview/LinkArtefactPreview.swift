//
//  LinkArtefactPreview.swift
//  Bentoshi
//
//  Created by Raquel Souza on 01/07/26.
//

import SwiftUI

struct LinkArtefactPreview: View {

    let name: String
    let url: String

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Image(systemName: "link")
                .font(.title2)

            Spacer()

            Text(name)
                .font(.headline)
                .lineLimit(2)

            Text(url)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding()
    }
}
