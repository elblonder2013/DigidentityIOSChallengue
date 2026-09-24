//
//  CatalogSceneDIContainer.swift
//  DigidentityIOSChallengue
//
//  Created by Alexei on 24/09/2026.
//

import SwiftData

/// Builds the catalog feature, from its data sources up to its view model.
@MainActor
final class CatalogSceneDIContainer {
    struct Dependencies {
        let apiClient: APIClient
        let modelContainer: ModelContainer
    }

    private let dependencies: Dependencies

    /// Shared by all use cases of the feature.
    private lazy var catalogRepository: CatalogRepository = DefaultCatalogRepository(
        remoteDataSource: DefaultCatalogRemoteDataSource(apiClient: dependencies.apiClient),
        localDataSource: DefaultCatalogLocalDataSource(modelContainer: dependencies.modelContainer)
    )

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: - Use Cases

    func makeGetCatalogItemsUseCase() -> GetCatalogItemsUseCase {
        DefaultGetCatalogItemsUseCase(repository: catalogRepository)
    }

    func makeLoadMoreCatalogItemsUseCase() -> LoadMoreCatalogItemsUseCase {
        DefaultLoadMoreCatalogItemsUseCase(repository: catalogRepository)
    }

    func makeRefreshCatalogItemsUseCase() -> RefreshCatalogItemsUseCase {
        DefaultRefreshCatalogItemsUseCase(repository: catalogRepository)
    }

    // MARK: - Catalog

    func makeCatalogViewModel() -> CatalogViewModel {
        CatalogViewModel(
            getCatalogItems: makeGetCatalogItemsUseCase(),
            loadMoreCatalogItems: makeLoadMoreCatalogItemsUseCase(),
            refreshCatalogItems: makeRefreshCatalogItemsUseCase()
        )
    }
}
