//
//  DefaultCatalogRemoteDataSource.swift
//  DigidentityIOSChallengue
//
//  Created by Alexei on 24/09/2026.
//

import Foundation

final class DefaultCatalogRemoteDataSource: CatalogRemoteDataSource {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchItems(sinceID: String?, maxID: String?) async throws -> [CatalogItemDTO] {
        try await apiClient.request(Self.itemsEndpoint(sinceID: sinceID, maxID: maxID))
    }

    private static func itemsEndpoint(sinceID: String?, maxID: String?) -> Endpoint<[CatalogItemDTO]> {
        var queryItems: [URLQueryItem] = []
        if let sinceID {
            queryItems.append(URLQueryItem(name: "since_id", value: sinceID))
        }
        if let maxID {
            queryItems.append(URLQueryItem(name: "max_id", value: maxID))
        }
        return Endpoint(path: "v1/items", queryItems: queryItems)
    }
}
