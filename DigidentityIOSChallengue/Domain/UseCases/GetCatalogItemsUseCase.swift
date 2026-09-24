//
//  GetCatalogItemsUseCase.swift
//  DigidentityIOSChallengue
//
//  Created by Alexei on 24/09/2026.
//

import Foundation

protocol GetCatalogItemsUseCase: Sendable {
    /// Emits the cached items first (when there are any), then the first page of fresh items.
    func execute() -> AsyncThrowingStream<[CatalogItem], Error>
}

final class DefaultGetCatalogItemsUseCase: GetCatalogItemsUseCase {
    private let repository: CatalogRepository

    init(repository: CatalogRepository) {
        self.repository = repository
    }

    func execute() -> AsyncThrowingStream<[CatalogItem], Error> {
        let repository = repository
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    // A broken cache must not block fresh data, so its errors are ignored.
                    if let cached = try? await repository.cachedItems(), !cached.isEmpty {
                        continuation.yield(cached)
                    }
                    continuation.yield(try await repository.fetchFirstPage())
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
