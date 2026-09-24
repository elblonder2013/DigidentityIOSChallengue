//
//  CatalogViewModelTests.swift
//  DigidentityIOSChallengueTests
//
//  Created by Alexei on 24/09/2026.
//

import XCTest
@testable import DigidentityIOSChallengue

@MainActor
final class CatalogViewModelTests: XCTestCase {
    private let getItems = GetCatalogItemsUseCaseMock()
    private let loadMore = LoadMoreCatalogItemsUseCaseMock()
    private let refresh = RefreshCatalogItemsUseCaseMock()

    // MARK: - Initial load

    func test_initialState_isIdleWithoutItems() {
        let sut = makeSUT()

        XCTAssertEqual(sut.state, .idle)
        XCTAssertEqual(sut.items, [])
        XCTAssertTrue(sut.hasMoreItems)
    }

    func test_onAppear_whileFetching_showsLoading() async {
        let gate = Gate()
        getItems.gate = gate
        getItems.emissions = [[.stub(id: "1")]]
        let sut = makeSUT()

        let task = Task { await sut.onAppear() }
        await waitUntil { sut.state == .loading }
        gate.open()
        await task.value

        XCTAssertEqual(sut.state, .loaded)
    }

    func test_onAppear_withItems_showsMappedItems() async {
        getItems.emissions = [[.stub(id: "2"), .stub(id: "1")]]
        let sut = makeSUT()

        await sut.onAppear()

        XCTAssertEqual(sut.state, .loaded)
        XCTAssertEqual(sut.items.map(\.id), ["2", "1"])
        XCTAssertNil(sut.errorMessage)
    }

    func test_onAppear_withCachedThenFreshItems_endsWithFreshItems() async {
        getItems.emissions = [[.stub(id: "1")], [.stub(id: "3"), .stub(id: "2")]]
        let sut = makeSUT()

        await sut.onAppear()

        XCTAssertEqual(sut.items.map(\.id), ["3", "2"])
    }

    func test_onAppear_withNoItems_showsEmpty() async {
        getItems.emissions = [[]]
        let sut = makeSUT()

        await sut.onAppear()

        XCTAssertEqual(sut.state, .empty)
    }

    func test_onAppear_whenFailingWithoutItems_showsError() async {
        getItems.error = TestError()
        let sut = makeSUT()

        await sut.onAppear()

        guard case .failed = sut.state else { return XCTFail("Expected failed state, got \(sut.state)") }
        XCTAssertEqual(sut.items, [])
    }

    func test_onAppear_whenFailingAfterCachedItems_keepsItemsAndShowsMessage() async {
        getItems.emissions = [[.stub(id: "1")]]
        getItems.error = TestError()
        let sut = makeSUT()

        await sut.onAppear()

        XCTAssertEqual(sut.state, .loaded)
        XCTAssertEqual(sut.items.map(\.id), ["1"])
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_onAppear_calledTwice_loadsOnce() async {
        getItems.emissions = [[.stub(id: "1")]]
        let sut = makeSUT()

        await sut.onAppear()
        await sut.onAppear()

        XCTAssertEqual(getItems.executeCallCount, 1)
    }

    func test_retry_afterFailure_loadsItems() async {
        getItems.error = TestError()
        let sut = makeSUT()
        await sut.onAppear()

        getItems.error = nil
        getItems.emissions = [[.stub(id: "1")]]
        await sut.retry()

        XCTAssertEqual(sut.state, .loaded)
        XCTAssertEqual(sut.items.map(\.id), ["1"])
    }

    // MARK: - Refresh

    func test_refresh_prependsNewerItems() async {
        let sut = await makeLoadedSUT(ids: ["2", "1"])
        refresh.result = .success([.stub(id: "4"), .stub(id: "3")])

        await sut.refresh()

        XCTAssertEqual(refresh.requestedIDs, ["2"])
        XCTAssertEqual(sut.items.map(\.id), ["4", "3", "2", "1"])
    }

    func test_refresh_skipsItemsAlreadyShown() async {
        let sut = await makeLoadedSUT(ids: ["2", "1"])
        refresh.result = .success([.stub(id: "3"), .stub(id: "2")])

        await sut.refresh()

        XCTAssertEqual(sut.items.map(\.id), ["3", "2", "1"])
    }

    func test_refresh_whenFailing_keepsItemsAndShowsMessage() async {
        let sut = await makeLoadedSUT(ids: ["1"])
        refresh.result = .failure(TestError())

        await sut.refresh()

        XCTAssertEqual(sut.items.map(\.id), ["1"])
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_refresh_withoutItems_performsInitialLoad() async {
        getItems.emissions = [[]]
        let sut = makeSUT()
        await sut.onAppear()

        getItems.emissions = [[.stub(id: "1")]]
        await sut.refresh()

        XCTAssertEqual(refresh.requestedIDs, [])
        XCTAssertEqual(sut.items.map(\.id), ["1"])
    }

    // MARK: - Load more

    func test_loadMore_appendsOlderItems() async {
        let sut = await makeLoadedSUT(ids: ["4", "3"])
        loadMore.result = .success([.stub(id: "2"), .stub(id: "1")])

        await sut.loadMore()

        XCTAssertEqual(loadMore.requestedIDs, ["3"])
        XCTAssertEqual(sut.items.map(\.id), ["4", "3", "2", "1"])
        XCTAssertEqual(sut.paginationState, .idle)
    }

    func test_loadMore_withNoOlderItems_stopsPaginating() async {
        let sut = await makeLoadedSUT(ids: ["1"])
        loadMore.result = .success([])

        await sut.loadMore()
        await sut.loadMore()

        XCTAssertFalse(sut.hasMoreItems)
        XCTAssertEqual(loadMore.requestedIDs, ["1"])
    }

    func test_loadMore_whileAlreadyLoading_doesNotSendDuplicateRequest() async {
        let sut = await makeLoadedSUT(ids: ["2"])
        let gate = Gate()
        loadMore.gate = gate
        loadMore.result = .success([.stub(id: "1")])

        let firstRequest = Task { await sut.loadMore() }
        await waitUntil { sut.paginationState == .loading }
        await sut.loadMore()
        await sut.loadMoreIfNeeded(currentItem: sut.items[0])
        gate.open()
        await firstRequest.value

        XCTAssertEqual(loadMore.requestedIDs, ["2"])
        XCTAssertEqual(sut.items.map(\.id), ["2", "1"])
    }

    func test_loadMore_whenFailing_keepsItemsAndAllowsRetry() async {
        let sut = await makeLoadedSUT(ids: ["2"])
        loadMore.result = .failure(TestError())

        await sut.loadMore()
        XCTAssertEqual(sut.paginationState, .failed)
        XCTAssertEqual(sut.items.map(\.id), ["2"])

        loadMore.result = .success([.stub(id: "1")])
        await sut.loadMore()

        XCTAssertEqual(sut.items.map(\.id), ["2", "1"])
        XCTAssertEqual(sut.paginationState, .idle)
    }

    func test_loadMoreIfNeeded_onlyTriggersForLastItem() async {
        let sut = await makeLoadedSUT(ids: ["2", "1"])

        await sut.loadMoreIfNeeded(currentItem: sut.items[0])
        XCTAssertEqual(loadMore.requestedIDs, [])

        await sut.loadMoreIfNeeded(currentItem: sut.items[1])
        XCTAssertEqual(loadMore.requestedIDs, ["1"])
    }

    // MARK: - Helpers

    private func makeSUT() -> CatalogViewModel {
        CatalogViewModel(getCatalogItems: getItems, loadMoreCatalogItems: loadMore, refreshCatalogItems: refresh)
    }

    private func makeLoadedSUT(ids: [String]) async -> CatalogViewModel {
        getItems.emissions = [ids.map { CatalogItem.stub(id: $0) }]
        let sut = makeSUT()
        await sut.onAppear()
        return sut
    }

    /// Lets other tasks run until `condition` holds, failing if it never does.
    private func waitUntil(
        file: StaticString = #filePath,
        line: UInt = #line,
        _ condition: () -> Bool
    ) async {
        for _ in 0..<1_000 {
            if condition() { return }
            await Task.yield()
        }
        XCTFail("Condition was never met", file: file, line: line)
    }
}
