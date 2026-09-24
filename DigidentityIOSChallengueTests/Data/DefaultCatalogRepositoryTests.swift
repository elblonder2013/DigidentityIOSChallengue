//
//  DefaultCatalogRepositoryTests.swift
//  DigidentityIOSChallengueTests
//
//  Created by Alexei on 24/09/2026.
//

import XCTest
@testable import DigidentityIOSChallengue

final class DefaultCatalogRepositoryTests: XCTestCase {
    private var remote: CatalogRemoteDataSourceMock!
    private var local: CatalogLocalDataSourceMock!
    private var sut: DefaultCatalogRepository!

    override func setUp() {
        super.setUp()
        remote = CatalogRemoteDataSourceMock()
        local = CatalogLocalDataSourceMock()
        sut = DefaultCatalogRepository(remoteDataSource: remote, localDataSource: local)
    }

    override func tearDown() {
        sut = nil
        local = nil
        remote = nil
        super.tearDown()
    }

    // MARK: - cachedItems

    func test_cachedItems_returnsLocalItems() async throws {
        let cached = [CatalogItem.stub(id: "2"), .stub(id: "1")]
        local.itemsResult = .success(cached)

        let items = try await sut.cachedItems()

        XCTAssertEqual(items, cached)
    }

    // MARK: - fetchFirstPage

    func test_fetchFirstPage_requestsWithoutIDsAndMapsRemoteItems() async throws {
        remote.results = [.success([
            CatalogItemDTO(id: "abc", text: "A photo", image: "https://example.com/a.png", confidence: 0.7)
        ])]

        let items = try await sut.fetchFirstPage()

        XCTAssertEqual(remote.requests, [.init(sinceID: nil, maxID: nil)])
        XCTAssertEqual(items, [CatalogItem(
            id: "abc",
            imageURL: URL(string: "https://example.com/a.png")!,
            description: "A photo",
            confidence: 0.7
        )])
    }

    func test_fetchFirstPage_savesRemoteItemsLocally() async throws {
        remote.results = [.success([.stub(id: "2"), .stub(id: "1")])]

        let items = try await sut.fetchFirstPage()

        XCTAssertEqual(local.savedBatches, [items])
    }

    func test_fetchFirstPage_skipsItemsWithInvalidImageURL() async throws {
        let invalid = CatalogItemDTO(id: "bad", text: "Bad", image: "", confidence: 0.1)
        remote.results = [.success([.stub(id: "2"), invalid, .stub(id: "1")])]

        let items = try await sut.fetchFirstPage()

        XCTAssertEqual(items.map(\.id), ["2", "1"])
    }

    func test_fetchFirstPage_whenSavingFails_stillReturnsRemoteItems() async throws {
        remote.results = [.success([.stub(id: "1")])]
        local.saveError = TestError()

        let items = try await sut.fetchFirstPage()

        XCTAssertEqual(items.map(\.id), ["1"])
    }

    func test_fetchFirstPage_whenRemoteFails_fallsBackToCache() async throws {
        let cached = [CatalogItem.stub(id: "1")]
        remote.results = [.failure(NetworkError.transport(URLError(.notConnectedToInternet)))]
        local.itemsResult = .success(cached)

        let items = try await sut.fetchFirstPage()

        XCTAssertEqual(items, cached)
    }

    func test_fetchFirstPage_whenRemoteFailsAndCacheIsEmpty_throwsRemoteError() async {
        remote.results = [.failure(TestError())]
        local.itemsResult = .success([])

        await assertThrowsTestError { try await self.sut.fetchFirstPage() }
    }

    func test_fetchFirstPage_whenRemoteAndCacheFail_throwsRemoteError() async {
        remote.results = [.failure(TestError())]
        local.itemsResult = .failure(NetworkError.invalidResponse)

        await assertThrowsTestError { try await self.sut.fetchFirstPage() }
    }

    func test_fetchFirstPage_whenCancelled_doesNotFallBackToCache() async {
        remote.results = [.failure(CancellationError())]
        local.itemsResult = .success([.stub(id: "1")])

        do {
            _ = try await sut.fetchFirstPage()
            XCTFail("Expected cancellation")
        } catch {
            XCTAssertTrue(error is CancellationError)
        }
    }

    // MARK: - fetchItems(olderThan:)

    func test_fetchOlder_requestsMaxIDAndSavesItems() async throws {
        remote.results = [.success([.stub(id: "9"), .stub(id: "8")])]

        let items = try await sut.fetchItems(olderThan: "10")

        XCTAssertEqual(remote.requests, [.init(sinceID: nil, maxID: "10")])
        XCTAssertEqual(items.map(\.id), ["9", "8"])
        XCTAssertEqual(local.savedBatches, [items])
    }

    func test_fetchOlder_excludesTheReferenceItem() async throws {
        remote.results = [.success([.stub(id: "10"), .stub(id: "9")])]

        let items = try await sut.fetchItems(olderThan: "10")

        XCTAssertEqual(items.map(\.id), ["9"])
    }

    func test_fetchOlder_propagatesRemoteError() async {
        remote.results = [.failure(TestError())]

        await assertThrowsTestError { try await self.sut.fetchItems(olderThan: "10") }
    }

    // MARK: - fetchItems(newerThan:)

    func test_fetchNewer_withPartialPage_requestsOnceAndReturnsItems() async throws {
        remote.results = [.success([.stub(id: "12"), .stub(id: "11")])]

        let items = try await sut.fetchItems(newerThan: "10")

        XCTAssertEqual(remote.requests, [.init(sinceID: "10", maxID: nil)])
        XCTAssertEqual(items.map(\.id), ["12", "11"])
        XCTAssertEqual(local.savedBatches, [items])
    }

    func test_fetchNewer_withFullPage_keepsRequestingFromNewestItem() async throws {
        let firstPage = (11...20).reversed().map { CatalogItemDTO.stub(id: "\($0)") }
        let secondPage = [CatalogItemDTO.stub(id: "22"), .stub(id: "21")]
        remote.results = [.success(firstPage), .success(secondPage)]

        let items = try await sut.fetchItems(newerThan: "10")

        XCTAssertEqual(remote.requests, [.init(sinceID: "10", maxID: nil), .init(sinceID: "20", maxID: nil)])
        XCTAssertEqual(items.map(\.id), ["22", "21"] + (11...20).reversed().map { "\($0)" })
    }

    func test_fetchNewer_whenUpToDate_returnsNoItems() async throws {
        remote.results = [.success([])]

        let items = try await sut.fetchItems(newerThan: "10")

        XCTAssertEqual(items, [])
    }

    func test_fetchNewer_propagatesRemoteError() async {
        remote.results = [.failure(TestError())]

        await assertThrowsTestError { try await self.sut.fetchItems(newerThan: "10") }
    }

    // MARK: - Helpers

    private func assertThrowsTestError(
        file: StaticString = #filePath,
        line: UInt = #line,
        _ operation: () async throws -> [CatalogItem]
    ) async {
        do {
            _ = try await operation()
            XCTFail("Expected an error", file: file, line: line)
        } catch {
            XCTAssertEqual(error as? TestError, TestError(), file: file, line: line)
        }
    }
}
