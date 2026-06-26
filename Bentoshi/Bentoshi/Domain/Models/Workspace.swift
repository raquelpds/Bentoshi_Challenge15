//
//  Workspace.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

import SwiftData
import Foundation
import SwiftUI

@Model
final class Workspace {
    var id: UUID
    var name: String
    var normalizedName: String
    var coverColor: WorkspaceColor
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .cascade)
    var artefacts: [Artefact]
    
    @Relationship(deleteRule: .cascade)
    var searchIndexes: [SearchIndex]
    
    init(name: String, coverColor: WorkspaceColor = .gray) {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
        self.normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        self.name = name
        self.artefacts = []
        self.searchIndexes = []
        self.coverColor = coverColor
        
        rebuildSearchIndexes()
    }
}

extension Workspace {

    func rebuildSearchIndexes() {

        searchIndexes.removeAll()

        for keyword in searchableKeywords {
            searchIndexes.append(
                SearchIndex(
                    keyword: keyword,
                    workspaceId: self.id,
                    workspace: self
                )
            )
        }
    }

    var searchableKeywords: [String] {
        name
            .lowercased()
            .folding(
                options: .diacriticInsensitive,
                locale: .current
            )
            .split(separator: " ")
            .map(String.init)
    }
}
