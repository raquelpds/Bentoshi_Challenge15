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

    var name: String
    var type: ArtefactType
    var content: String
    var workspaceId: UUID
    var createdAt: Date
    var updatedAt: Date
    
    var width: Double
    var height: Double
    var positionX: Int
    var positionY: Int
    
    var bookmark: Data?
    var workspace: Workspace?

    @Relationship(deleteRule: .cascade)
    var searchIndexes: [SearchIndex]

    init(name: String, type: ArtefactType, content: String, workspaceId: UUID, width: Double, height: Double, positionX: Int, positionY: Int, bookmark: Data? = nil) {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
        
        self.name = name
        self.type = type
        self.content = content
        self.workspaceId = workspaceId

        self.width = width
        self.height = height

        self.positionX = positionX
        self.positionY = positionY
        self.bookmark = bookmark

        self.searchIndexes = []

        rebuildAutomaticSearchIndexes()
    }
}

extension Artefact {

    var searchableKeywords: [String] {

        let rawKeywords: [String]

        switch type {

        case .text:
            rawKeywords = extractKeywords(
                from: [
                    name,
                    content
                ]
            )

        case .link:
            rawKeywords = extractKeywords(
                from: [
                    normalizedLinkName,
                    extractURLKeywords(content)
                ]
            )

        default:
            rawKeywords = extractKeywords(
                from: [
                    name
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
    
    var archiveUrl: URL? {
        var isStale = false

        guard let bookmark = bookmark, let resolvedUrl = try? URL(
            resolvingBookmarkData: bookmark,
            options: [.withSecurityScope],
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        ) else {
            return nil
        }

        return resolvedUrl
    }
}

extension Artefact {
    func checkIsMissingArchivePath() -> Bool {
        guard let url = archiveUrl else { return true }
        return !FileManager.default.fileExists(
            atPath: url.path
        )
    }
}

extension Artefact {
    
    func rebuildAutomaticSearchIndexes() {
        searchIndexes.removeAll { index in
            index.source == .automatic
        }

        for keyword in searchableKeywords {
            searchIndexes.append(
                SearchIndex(
                    keyword: keyword,
                    workspaceId: workspaceId,
                    source: .automatic,
                    artefact: self
                )
            )
        }
    }
    
    func addManualSearchKeyword(_ keyword: String) {
        let normalizedKeyword = normalize(keyword)

        guard !normalizedKeyword.isEmpty else { return }

        searchIndexes.append(
            SearchIndex(
                keyword: normalizedKeyword,
                workspaceId: workspaceId,
                source: .manual,
                artefact: self
            )
        )
    }

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

    var normalizedLinkName: String {

        let normalizedTitle =
            normalize(name)

        let normalizedContent =
            normalize(content)

        if normalizedTitle == normalizedContent {
            return extractURLKeywords(content)
        }

        return name
    }
}
