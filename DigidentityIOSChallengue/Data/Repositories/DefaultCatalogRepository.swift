//
//  DefaultCatalogRepository.swift
//  DigidentityIOSChallengue
//
//  Created by Alexei on 24/09/2026.
//

import Foundation

final class DefaultCatalogRepository: CatalogRepository {
    /// Items the API returns per request.
    private static let pageSize = 10

    private let remoteDataSource: CatalogRemoteDataSource
    private let localDataSource: CatalogLocalDataSource

    init(remoteDataSource: CatalogRemoteDataSource, localDataSource: CatalogLocalDataSource) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    func cachedItems() async throws -> [CatalogItem] {
        try await localDataSource.items()
    }

    func fetchFirstPage() async throws -> [CatalogItem] {
        do {
            let items = try await fetchPage(sinceID: nil, maxID: nil)
            await cache(items)
            return items
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            let cached = (try? await localDataSource.items()) ?? []
            guard !cached.isEmpty else { throw error }
            return cached
        }
    }

    func fetchItems(olderThan id: String) async throws -> [CatalogItem] {
        // The API documents `max_id` as inclusive, so the reference item may come back again.
        let items = try await fetchPage(sinceID: nil, maxID: id).filter { $0.id != id }
        await cache(items)
        return items
    }

    func fetchItems(newerThan id: String) async throws -> [CatalogItem] {
        // `since_id` returns the page right above the given ID, so full pages mean there may be more.
        var newerItems: [CatalogItem] = []
        var seenIDs: Set<String> = [id]
        var cursor = id
        while true {
            let page = try await remoteDataSource.fetchItems(sinceID: cursor, maxID: nil)
            let newItems = page.compactMap { $0.toDomain() }.filter { seenIDs.insert($0.id).inserted }
            newerItems = newItems + newerItems
            guard page.count >= Self.pageSize, let newest = newItems.first else { break }
            cursor = newest.id
        }
        await cache(newerItems)
        return newerItems
    }

    // MARK: - Private

    private func fetchPage(sinceID: String?, maxID: String?) async throws -> [CatalogItem] {
        try await remoteDataSource
            .fetchItems(sinceID: sinceID, maxID: maxID)
            .compactMap { $0.toDomain() }
    }

    /// Caching is best effort: fresh data is still returned when it cannot be stored.
    private func cache(_ items: [CatalogItem]) async {
        try? await localDataSource.save(items)
    }
}
