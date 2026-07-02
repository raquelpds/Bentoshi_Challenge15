//
//  SearchResultRow.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 21/06/26.
//

import SwiftUI

struct ArtefactSearchRow: View {
    
    let artefact: Artefact
    let showWorkspaceName: Bool
    let action: () -> Void
    
    init(artefact: Artefact, showWorkspaceName: Bool = false, action: @escaping () -> Void) {
        self.artefact = artefact
        self.showWorkspaceName = showWorkspaceName
        self.action = action
    }
    
    var body: some View {
        
        Button {
            action()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    
                    if showWorkspaceName, let workspace = artefact.workspace {
                        Text(workspace.name)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: icon)
                        Text(artefact.name)
                            .font(.headline)
                    }
                    
                }
                .padding(10)
                
                Spacer()
            }
            
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
