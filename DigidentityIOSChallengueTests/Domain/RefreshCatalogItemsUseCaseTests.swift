//
//  RefreshCatalogItemsUseCaseTests.swift
//  DigidentityIOSChallengueTests
//
//  Created by Alexei on 24/09/2026.
//

import XCTest
@testable import DigidentityIOSChallengue

final class RefreshCatalogItemsUseCaseTests: XCTestCase {
    private var repository: CatalogRepositoryMock!
    private var sut: DefaultRefreshCatalogItemsUseCase!

    override func setUp() {
        super.setUp()
        repository = CatalogRepositoryMock()
        sut = DefaultRefreshCatalogItemsUseCase(repository: repository)
    }

    override func tearDown() {
        sut = nil
        repository = nil
        super.tearDown()
    }

    func test_execute_requestsItemsNewerThanFirstItemAndReturnsThem() async throws {
        let newerItems = [CatalogItem.stub(id: "12"), .stub(id: "11")]
        repository.fetchNewerResult = .success(newerItems)

        let items = try await sut.execute(newerThan: "10")

        XCTAssertEqual(items, newerItems)
        XCTAssertEqual(repository.requestedNewerThanIDs, ["10"])
    }

    func test_execute_propagatesRepositoryError() async {
        repository.fetchNewerResult = .failure(TestError())

        do {
            _ = try await sut.execute(newerThan: "10")
            XCTFail("Expected an error")
        } catch {
            XCTAssertEqual(error as? TestError, TestError())
        }
    }
}
