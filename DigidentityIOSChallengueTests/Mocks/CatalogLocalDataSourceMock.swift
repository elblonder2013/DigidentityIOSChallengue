//
//  CatalogLocalDataSourceMock.swift
//  DigidentityIOSChallengueTests
//
//  Created by Alexei on 24/09/2026.
//

import Foundation
@testable import DigidentityIOSChallengue

/// Configured before use and read after the awaited call finishes, so it is never accessed concurrently.
final class CatalogLocalDataSourceMock: CatalogLocalDataSource, @unchecked Sendable {
    var itemsResult: Result<[CatalogItem], Error> = .success([])
    var saveError: Error?
    private(set) var savedBatches: [[CatalogItem]] = []

    func items() async throws -> [CatalogItem] {
        try itemsResult.get()
    }

    func save(_ items: [CatalogItem]) async throws {
        if let saveError { throw saveError }
        savedBatches.append(items)
    }
}
