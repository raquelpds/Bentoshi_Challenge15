//
//  ArtefactType.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

enum ArtefactType: String, Codable, CaseIterable {
    
    case link = "Link"
    case archive = "Arquivo"
    case text = "Texto"
    
}

extension ArtefactType {

    var defaultWidth: Int {
        switch self {
        case .link:
            return 3

        case .text:
            return 2

        case .archive:
            return 3
        }
    }

    var defaultHeight: Int {
        switch self {
        case .link:
            return 1

        case .text:
            return 3

        case .archive:
            return 3
        }
    }
}
