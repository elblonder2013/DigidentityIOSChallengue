//
//  CatalogRepository.swift
//  DigidentityIOSChallengue
//
//  Created by Alexei on 24/09/2026.
//

import Foundation

/// Source of catalog items. All results are ordered newest first.
protocol CatalogRepository: Sendable {
    /// Items stored locally from previous sessions. Empty when nothing is cached.
    func cachedItems() async throws -> [CatalogItem]

    /// The most recent page of items. Falls back to the cached items when they cannot be fetched.
    func fetchFirstPage() async throws -> [CatalogItem]

    /// The next page of items older than the given ID. Empty when there are no older items.
    func fetchItems(olderThan id: String) async throws -> [CatalogItem]

    /// All items newer than the given ID. Empty when there are no newer items.
    func fetchItems(newerThan id: String) async throws -> [CatalogItem]
}
