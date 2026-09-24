//
//  LoadMoreCatalogItemsUseCase.swift
//  DigidentityIOSChallengue
//
//  Created by Alexei on 24/09/2026.
//

import Foundation

protocol LoadMoreCatalogItemsUseCase: Sendable {
    /// Returns the next page of items older than `lastItemID`. Empty when the end of the catalog is reached.
    func execute(olderThan lastItemID: String) async throws -> [CatalogItem]
}

final class DefaultLoadMoreCatalogItemsUseCase: LoadMoreCatalogItemsUseCase {
    private let repository: CatalogRepository

    init(repository: CatalogRepository) {
        self.repository = repository
    }

    func execute(olderThan lastItemID: String) async throws -> [CatalogItem] {
        try await repository.fetchItems(olderThan: lastItemID)
    }
}
