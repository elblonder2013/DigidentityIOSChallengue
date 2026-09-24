//
//  RefreshCatalogItemsUseCase.swift
//  DigidentityIOSChallengue
//
//  Created by Alexei on 24/09/2026.
//

import Foundation

protocol RefreshCatalogItemsUseCase: Sendable {
    /// Returns the items newer than `firstItemID`. Empty when the catalog is up to date.
    func execute(newerThan firstItemID: String) async throws -> [CatalogItem]
}

final class DefaultRefreshCatalogItemsUseCase: RefreshCatalogItemsUseCase {
    private let repository: CatalogRepository

    init(repository: CatalogRepository) {
        self.repository = repository
    }

    func execute(newerThan firstItemID: String) async throws -> [CatalogItem] {
        try await repository.fetchItems(newerThan: firstItemID)
    }
}
