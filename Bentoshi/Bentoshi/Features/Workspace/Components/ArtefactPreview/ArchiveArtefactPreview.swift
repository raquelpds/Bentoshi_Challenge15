//
//  ArchiveArtefactPreview.swift
//  Bentoshi
//
//  Created by Raquel Souza on 01/07/26.
//

import SwiftUI

struct ArchiveArtefactPreview: View {

    let title: String
    let fileName: String

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Image(systemName: "doc")

                .font(.largeTitle)

            Spacer()

            Text(title)

                .font(.headline)

                .lineLimit(2)

            Text(fileName)

                .font(.caption)

                .foregroundStyle(.secondary)

                .lineLimit(2)

        }
        .padding()
    }
}
