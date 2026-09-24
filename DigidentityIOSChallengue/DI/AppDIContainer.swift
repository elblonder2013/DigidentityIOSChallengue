//
//  AppDIContainer.swift
//  DigidentityIOSChallengue
//
//  Created by Alexei on 24/09/2026.
//

import Foundation
import SwiftData

/// Owns the dependencies shared by the whole app and creates the containers of each feature.
@MainActor
final class AppDIContainer {
    private let configuration: AppConfiguration

    private lazy var apiClient: APIClient = DefaultAPIClient(
        config: NetworkConfig(
            baseURL: configuration.apiBaseURL,
            headers: ["Authorization": configuration.apiToken]
        )
    )

    private lazy var modelContainer: ModelContainer = Self.makeModelContainer()

    init(configuration: AppConfiguration = AppConfiguration()) {
        self.configuration = configuration
    }

    func makeCatalogSceneDIContainer() -> CatalogSceneDIContainer {
        CatalogSceneDIContainer(dependencies: .init(apiClient: apiClient, modelContainer: modelContainer))
    }

    /// Falls back to an in-memory store so the app still works, without a cache, if the store cannot be opened.
    private static func makeModelContainer() -> ModelContainer {
        do {
            return try ModelContainer(for: CatalogItemEntity.self)
        } catch {
            assertionFailure("Could not open the persistent store: \(error)")
            do {
                return try ModelContainer(
                    for: CatalogItemEntity.self,
                    configurations: ModelConfiguration(isStoredInMemoryOnly: true)
                )
            } catch {
                fatalError("Could not create an in-memory store: \(error)")
            }
        }
    }
}
