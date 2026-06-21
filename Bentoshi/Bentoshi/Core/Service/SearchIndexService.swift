//
//  SearchIndexService.swift
//  Bentoshi
//
//  Created by Lizandra Malta on 21/06/26.
//

import SwiftData
import Foundation

final class SearchIndexService: SearchIndexServiceProtocol {

    private let storage: StorageService<SearchIndex>
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        self.storage = StorageService(context: context)
    }

    func delete(id: PersistentIdentifier) throws {
        try storage.remove(id: id)
    }

    func globalSearch(_ text: String) throws -> [SearchIndex] {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedText.isEmpty else {
            return []
        }

        let descriptor = FetchDescriptor<SearchIndex>(
            predicate: #Predicate<SearchIndex> { item in
                item.keyword.localizedStandardContains(trimmedText)
            },
            sortBy: [
                SortDescriptor(\.keyword, order: .forward)
            ]
        )

        return try context.fetch(descriptor)
    }
    
    func searchArtefactFromWorkspaceWithId(_ id: UUID, text: String) throws -> [SearchIndex] {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedText.isEmpty else {
            return []
        }

        let descriptor = FetchDescriptor<SearchIndex>(
            predicate: #Predicate<SearchIndex> { item in
                item.workspaceId == id &&
                item.keyword.localizedStandardContains(trimmedText)
            },
            sortBy: [
                SortDescriptor(\.keyword, order: .forward)
            ]
        )

        return try context.fetch(descriptor)
    }
}
