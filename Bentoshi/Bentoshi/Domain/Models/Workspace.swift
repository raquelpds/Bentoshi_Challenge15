//
//  Workspace.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

import SwiftData
import Foundation

@Model
final class Workspace {
    var id: UUID
    var title: String
    var coverColor: String
    
    @Relationship(deleteRule: .cascade)
    var artefacts: [Artefact]
    
    @Relationship(deleteRule: .cascade)
    var searchIndexes: [SearchIndex]
    
    init(title: String, coverColor: String) {
        self.id = UUID()
        self.title = title
        self.coverColor = coverColor
        self.artefacts = []
        self.searchIndexes = []
        
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
                    workspace: self
                )
            )
        }
    }

    var searchableKeywords: [String] {
        title
            .lowercased()
            .folding(
                options: .diacriticInsensitive,
                locale: .current
            )
            .split(separator: " ")
            .map(String.init)
    }
}
