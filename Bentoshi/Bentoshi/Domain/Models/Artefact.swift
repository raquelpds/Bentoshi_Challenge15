//
//  Workspace.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 17/06/26.
//

import SwiftData
import Foundation

@Model
final class Artefact {

    var id: UUID

    var title: String
    var type: ArtefactType
    var content: String

    var width: Double
    var height: Double
    var positionX: Int
    var positionY: Int

    @Relationship(deleteRule: .cascade)
    var searchIndexes: [SearchIndex]

    init(title: String, type: ArtefactType, content: String, width: Double, height: Double, positionX: Int, positionY: Int) {
        self.id = UUID()

        self.title = title
        self.type = type
        self.content = content

        self.width = width
        self.height = height

        self.positionX = positionX
        self.positionY = positionY

        self.searchIndexes = []

        rebuildSearchIndexes()
    }
}

extension Artefact {

    func rebuildSearchIndexes() {

        searchIndexes.removeAll()

        for keyword in searchableKeywords {

            searchIndexes.append(
                SearchIndex(
                    keyword: keyword,
                    workspace: nil,
                    artefact: self
                )
            )
        }
    }

    var searchableKeywords: [String] {

        let rawKeywords: [String]

        switch type {

        case .text:
            rawKeywords = extractKeywords(
                from: [
                    title,
                    content
                ]
            )

        case .link:
            rawKeywords = extractKeywords(
                from: [
                    normalizedLinkTitle,
                    extractURLKeywords(content)
                ]
            )

        default:
            rawKeywords = extractKeywords(
                from: [
                    title
                ]
            )
        }

        return Array(
            Set(
                rawKeywords.filter {
                    !$0.isEmpty
                }
            )
        )
    }
}

private extension Artefact {

    func extractKeywords(from values: [String]) -> [String] {
        values
            .flatMap {
                normalize($0)
                    .split(whereSeparator: \.isWhitespace)
            }
            .map(String.init)
    }

    func extractURLKeywords(_ urlString: String) -> String {

        guard let url = URL(string: urlString) else {
            return urlString
        }

        let host =
            url.host?
            .replacingOccurrences(of: ".", with: " ")
            .replacingOccurrences(of: "-", with: " ")

        let path =
            url.path
            .replacingOccurrences(of: "/", with: " ")
            .replacingOccurrences(of: "-", with: " ")

        return "\(host ?? "") \(path)"
    }

    func normalize(_ value: String) -> String {

        value
            .lowercased()
            .folding(
                options: .diacriticInsensitive,
                locale: .current
            )
    }

    var normalizedLinkTitle: String {

        let normalizedTitle =
            normalize(title)

        let normalizedContent =
            normalize(content)

        if normalizedTitle == normalizedContent {
            return extractURLKeywords(content)
        }

        return title
    }
}
