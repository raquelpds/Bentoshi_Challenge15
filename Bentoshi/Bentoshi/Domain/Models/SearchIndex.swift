//
//  SearchIndex.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

import SwiftData
import Foundation

@Model
final class SearchIndex {
    var id: UUID
    var workspaceId: UUID
    var source: SearchIndexSource
    var keyword: String
    
    @Relationship
    var workspace: Workspace?
    
    @Relationship
    var artefact: Artefact?
    
    init(keyword: String,  workspaceId: UUID, source: SearchIndexSource = .automatic, workspace: Workspace? = nil, artefact: Artefact? = nil) {
        self.id = UUID()
        self.workspaceId = workspaceId
        self.source = source
        self.keyword = keyword
        self.workspace = workspace
        self.artefact = artefact
    }
}
