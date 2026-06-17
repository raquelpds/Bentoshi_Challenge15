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
    var keyword: String
    var workspace: Workspace?
    var artefact: Artefact?
    
    init(keyword: String, workspace: Workspace? = nil, artefact: Artefact? = nil) {
        self.id = UUID()
        self.keyword = keyword
        self.workspace = workspace
        self.artefact = artefact
    }
}
