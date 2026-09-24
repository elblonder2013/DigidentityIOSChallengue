//
//  CatalogRepositoryMock.swift
//  DigidentityIOSChallengueTests
//
//  Created by Alexei on 24/09/2026.
//

import Foundation
@testable import DigidentityIOSChallengue

/// Configured before use and read after the awaited call finishes, so it is never accessed concurrently.
final class CatalogRepositoryMock: CatalogRepository, @unchecked Sendable {
    var cachedItemsResult: Result<[CatalogItem], Error> = .success([])
    var fetchFirstPageResult: Result<[CatalogItem], Error> = .success([])
    var fetchOlderResult: Result<[CatalogItem], Error> = .success([])
    var fetchNewerResult: Result<[CatalogItem], Error> = .success([])

    private(set) var fetchFirstPageCallCount = 0
    private(set) var requestedOlderThanIDs: [String] = []
    private(set) var requestedNewerThanIDs: [String] = []

    func cachedItems() async throws -> [CatalogItem] {
        try cachedItemsResult.get()
    }

    func fetchFirstPage() async throws -> [CatalogItem] {
        fetchFirstPageCallCount += 1
        return try fetchFirstPageResult.get()
    }

    func fetchItems(olderThan id: String) async throws -> [CatalogItem] {
        requestedOlderThanIDs.append(id)
        return try fetchOlderResult.get()
    }

    func fetchItems(newerThan id: String) async throws -> [CatalogItem] {
        requestedNewerThanIDs.append(id)
        return try fetchNewerResult.get()
    }
}
