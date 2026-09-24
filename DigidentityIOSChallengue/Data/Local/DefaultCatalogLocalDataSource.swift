//
//  DefaultCatalogLocalDataSource.swift
//  DigidentityIOSChallengue
//
//  Created by Alexei on 24/09/2026.
//

import Foundation
import SwiftData

/// Runs SwiftData work on its own actor and only hands out domain values, since models are not `Sendable`.
@ModelActor
actor DefaultCatalogLocalDataSource: CatalogLocalDataSource {
    func items() throws -> [CatalogItem] {
        // The API defines recency by ID ("greater than" means newer), so ID order is the catalog order.
        let descriptor = FetchDescriptor<CatalogItemEntity>(sortBy: [SortDescriptor(\.id, order: .reverse)])
        return try modelContext.fetch(descriptor).map { $0.toDomain() }
    }

    func save(_ items: [CatalogItem]) throws {
        guard !items.isEmpty else { return }

        let ids = items.map(\.id)
        let existing = try modelContext.fetch(FetchDescriptor<CatalogItemEntity>(
            predicate: #Predicate { ids.contains($0.id) }
        ))
        let existingByID = Dictionary(existing.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

        for item in items {
            if let entity = existingByID[item.id] {
                entity.update(from: item)
            } else {
                modelContext.insert(CatalogItemEntity(item: item))
            }
        }
        try modelContext.save()
    }
}
