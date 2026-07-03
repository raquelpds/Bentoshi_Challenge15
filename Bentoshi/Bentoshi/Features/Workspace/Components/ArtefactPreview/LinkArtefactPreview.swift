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

            HStack{
                Image(systemName: "link")
                    .bold()
                Text(name)
                    .font(.title2)
                    .bold()
                    .lineLimit(2)
            }
        }
        .padding()
    }
}
