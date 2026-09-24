//
//  CatalogLocalDataSource.swift
//  DigidentityIOSChallengue
//
//  Created by Alexei on 24/09/2026.
//

import Foundation

protocol CatalogLocalDataSource: Sendable {
    /// All stored items, newest first.
    func items() async throws -> [CatalogItem]

    /// Inserts new items and updates the ones already stored with the same ID.
    func save(_ items: [CatalogItem]) async throws
}
