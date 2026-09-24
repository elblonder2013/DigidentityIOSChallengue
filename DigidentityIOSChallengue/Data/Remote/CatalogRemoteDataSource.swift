//
//  CatalogRemoteDataSource.swift
//  DigidentityIOSChallengue
//
//  Created by Alexei on 24/09/2026.
//

import Foundation

protocol CatalogRemoteDataSource: Sendable {
    /// Fetches one page of items, newest first.
    /// - Parameters:
    ///   - sinceID: Only items newer than this ID.
    ///   - maxID: Only items older than this ID.
    func fetchItems(sinceID: String?, maxID: String?) async throws -> [CatalogItemDTO]
}
