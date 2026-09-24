//
//  CatalogRemoteDataSourceMock.swift
//  DigidentityIOSChallengueTests
//
//  Created by Alexei on 24/09/2026.
//

import Foundation
@testable import DigidentityIOSChallengue

/// Answers each call with the next queued result. Configured before use and read after the awaited call finishes.
final class CatalogRemoteDataSourceMock: CatalogRemoteDataSource, @unchecked Sendable {
    struct Request: Equatable {
        let sinceID: String?
        let maxID: String?
    }

    var results: [Result<[CatalogItemDTO], Error>] = []
    private(set) var requests: [Request] = []

    func fetchItems(sinceID: String?, maxID: String?) async throws -> [CatalogItemDTO] {
        requests.append(Request(sinceID: sinceID, maxID: maxID))
        guard !results.isEmpty else { return [] }
        return try results.removeFirst().get()
    }
}
