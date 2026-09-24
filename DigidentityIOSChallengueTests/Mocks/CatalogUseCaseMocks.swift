//
//  CatalogUseCaseMocks.swift
//  DigidentityIOSChallengueTests
//
//  Created by Alexei on 24/09/2026.
//

import Foundation
@testable import DigidentityIOSChallengue

// These mocks are configured before use and read after the awaited call finishes, so they are never accessed concurrently.

final class GetCatalogItemsUseCaseMock: GetCatalogItemsUseCase, @unchecked Sendable {
    var emissions: [[CatalogItem]] = []
    var error: Error?
    /// When set, nothing is emitted until the gate opens.
    var gate: Gate?
    private(set) var executeCallCount = 0

    func execute() -> AsyncThrowingStream<[CatalogItem], Error> {
        executeCallCount += 1
        let emissions = emissions
        let error = error
        let gate = gate
        return AsyncThrowingStream { continuation in
            Task {
                await gate?.wait()
                emissions.forEach { continuation.yield($0) }
                continuation.finish(throwing: error)
            }
        }
    }
}

final class LoadMoreCatalogItemsUseCaseMock: LoadMoreCatalogItemsUseCase, @unchecked Sendable {
    var result: Result<[CatalogItem], Error> = .success([])
    /// When set, the call does not return until the gate opens.
    var gate: Gate?
    private(set) var requestedIDs: [String] = []

    func execute(olderThan lastItemID: String) async throws -> [CatalogItem] {
        requestedIDs.append(lastItemID)
        await gate?.wait()
        return try result.get()
    }
}

final class RefreshCatalogItemsUseCaseMock: RefreshCatalogItemsUseCase, @unchecked Sendable {
    var result: Result<[CatalogItem], Error> = .success([])
    private(set) var requestedIDs: [String] = []

    func execute(newerThan firstItemID: String) async throws -> [CatalogItem] {
        requestedIDs.append(firstItemID)
        return try result.get()
    }
}
