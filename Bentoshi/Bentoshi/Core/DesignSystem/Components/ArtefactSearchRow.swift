//
//  SearchResultRow.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 21/06/26.
//

import SwiftUI

struct ArtefactSearchRow: View {
    
    let artefact: Artefact
    let action: () -> Void
    
    var body: some View {
        
        Button {
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(artefact.name)
                        .font(.headline)
                    
                    Text(artefact.type.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 12)
        }
    }
    
    private var icon: String {
        switch artefact.type {
        case .link:
            return "link"
        case .archive:
            return "archivebox"
        case .text:
            return "doc.text"
        }
    }
}
