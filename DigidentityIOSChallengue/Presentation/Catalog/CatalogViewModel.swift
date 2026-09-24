//
//  CatalogViewModel.swift
//  DigidentityIOSChallengue
//
//  Created by Alexei on 24/09/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class CatalogViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case empty
        case failed(message: String)
    }

    enum PaginationState: Equatable {
        case idle
        case loading
        case failed
        case finished
    }

    private(set) var items: [CatalogItemViewData] = []
    private(set) var state: State = .idle
    private(set) var paginationState: PaginationState = .idle
    /// A problem that does not replace the list, e.g. a failed refresh while items are shown.
    var errorMessage: String?

    var hasMoreItems: Bool { paginationState != .finished }

    private let getCatalogItems: GetCatalogItemsUseCase
    private let loadMoreCatalogItems: LoadMoreCatalogItemsUseCase
    private let refreshCatalogItems: RefreshCatalogItemsUseCase

    init(
        getCatalogItems: GetCatalogItemsUseCase,
        loadMoreCatalogItems: LoadMoreCatalogItemsUseCase,
        refreshCatalogItems: RefreshCatalogItemsUseCase
    ) {
        self.getCatalogItems = getCatalogItems
        self.loadMoreCatalogItems = loadMoreCatalogItems
        self.refreshCatalogItems = refreshCatalogItems
    }

    // MARK: - Actions

    func onAppear() async {
        guard state == .idle else { return }
        await load()
    }

    func retry() async {
        await load()
    }

    func refresh() async {
        guard state != .loading else { return }
        guard let firstID = items.first?.id else {
            await load()
            return
        }
        do {
            let newerItems = try await refreshCatalogItems.execute(newerThan: firstID)
            insert(newerItems, atStart: true)
        } catch is CancellationError {
            // The refresh was abandoned, the current list stays valid.
        } catch {
            errorMessage = Self.refreshErrorMessage
        }
    }

    func loadMoreIfNeeded(currentItem: CatalogItemViewData) async {
        guard currentItem.id == items.last?.id, paginationState == .idle else { return }
        await loadMore()
    }

    /// Loads the next page. Ignored while a page is already loading or when there are no more items.
    func loadMore() async {
        guard state == .loaded,
              paginationState == .idle || paginationState == .failed,
              let lastID = items.last?.id else { return }

        paginationState = .loading
        do {
            let olderItems = try await loadMoreCatalogItems.execute(olderThan: lastID)
            insert(olderItems, atStart: false)
            paginationState = olderItems.isEmpty ? .finished : .idle
        } catch is CancellationError {
            paginationState = .idle
        } catch {
            paginationState = .failed
        }
    }

    // MARK: - Private

    private func load() async {
        if items.isEmpty {
            state = .loading
        }
        errorMessage = nil

        do {
            for try await catalogItems in getCatalogItems.execute() {
                items = catalogItems.map { CatalogItemViewData(item: $0) }
                state = items.isEmpty ? .empty : .loaded
                if paginationState != .loading {
                    paginationState = .idle
                }
            }
        } catch is CancellationError {
            // Handled below together with a stream that ended because the task was cancelled.
        } catch {
            if items.isEmpty {
                state = .failed(message: Self.loadErrorMessage)
            } else {
                errorMessage = Self.loadErrorMessage
            }
        }

        if state == .loading {
            state = .idle
        }
    }

    /// Adds items to one end of the list, skipping those already shown.
    private func insert(_ newItems: [CatalogItem], atStart: Bool) {
        let knownIDs = Set(items.map(\.id))
        let viewData = newItems
            .filter { !knownIDs.contains($0.id) }
            .map { CatalogItemViewData(item: $0) }
        items = atStart ? viewData + items : items + viewData
    }

    private static let loadErrorMessage = "Couldn't load the catalog. Check your connection and try again."
    private static let refreshErrorMessage = "Couldn't refresh the catalog. Check your connection and try again."
}
