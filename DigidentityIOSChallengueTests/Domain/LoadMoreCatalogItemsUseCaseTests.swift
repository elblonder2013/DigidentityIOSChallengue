//
//  LoadMoreCatalogItemsUseCaseTests.swift
//  DigidentityIOSChallengueTests
//
//  Created by Alexei on 24/09/2026.
//

import XCTest
@testable import DigidentityIOSChallengue

final class LoadMoreCatalogItemsUseCaseTests: XCTestCase {
    private var repository: CatalogRepositoryMock!
    private var sut: DefaultLoadMoreCatalogItemsUseCase!

    override func setUp() {
        super.setUp()
        repository = CatalogRepositoryMock()
        sut = DefaultLoadMoreCatalogItemsUseCase(repository: repository)
    }

    override func tearDown() {
        sut = nil
        repository = nil
        super.tearDown()
    }

    func test_execute_requestsItemsOlderThanLastItemAndReturnsThem() async throws {
        let olderItems = [CatalogItem.stub(id: "9"), .stub(id: "8")]
        repository.fetchOlderResult = .success(olderItems)

        let items = try await sut.execute(olderThan: "10")

        XCTAssertEqual(items, olderItems)
        XCTAssertEqual(repository.requestedOlderThanIDs, ["10"])
    }

    func test_execute_propagatesRepositoryError() async {
        repository.fetchOlderResult = .failure(TestError())

        do {
            _ = try await sut.execute(olderThan: "10")
            XCTFail("Expected an error")
        } catch {
            XCTAssertEqual(error as? TestError, TestError())
        }
    }
}
