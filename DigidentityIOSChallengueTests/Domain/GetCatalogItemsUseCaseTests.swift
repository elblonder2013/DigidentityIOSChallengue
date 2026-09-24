//
//  GetCatalogItemsUseCaseTests.swift
//  DigidentityIOSChallengueTests
//
//  Created by Alexei on 24/09/2026.
//

import XCTest
@testable import DigidentityIOSChallengue

final class GetCatalogItemsUseCaseTests: XCTestCase {
    private var repository: CatalogRepositoryMock!
    private var sut: DefaultGetCatalogItemsUseCase!

    override func setUp() {
        super.setUp()
        repository = CatalogRepositoryMock()
        sut = DefaultGetCatalogItemsUseCase(repository: repository)
    }

    override func tearDown() {
        sut = nil
        repository = nil
        super.tearDown()
    }

    func test_execute_withoutCache_emitsOnlyFirstPage() async throws {
        let firstPage = [CatalogItem.stub(id: "2"), .stub(id: "1")]
        repository.fetchFirstPageResult = .success(firstPage)

        let emissions = try await collect(sut.execute())

        XCTAssertEqual(emissions, [firstPage])
    }

    func test_execute_withCache_emitsCachedItemsThenFirstPage() async throws {
        let cached = [CatalogItem.stub(id: "1")]
        let firstPage = [CatalogItem.stub(id: "2"), .stub(id: "1")]
        repository.cachedItemsResult = .success(cached)
        repository.fetchFirstPageResult = .success(firstPage)

        let emissions = try await collect(sut.execute())

        XCTAssertEqual(emissions, [cached, firstPage])
    }

    func test_execute_whenCacheFails_stillEmitsFirstPage() async throws {
        let firstPage = [CatalogItem.stub(id: "1")]
        repository.cachedItemsResult = .failure(TestError())
        repository.fetchFirstPageResult = .success(firstPage)

        let emissions = try await collect(sut.execute())

        XCTAssertEqual(emissions, [firstPage])
    }

    func test_execute_whenFirstPageFails_propagatesErrorAfterCachedItems() async {
        let cached = [CatalogItem.stub(id: "1")]
        repository.cachedItemsResult = .success(cached)
        repository.fetchFirstPageResult = .failure(TestError())
        var emissions: [[CatalogItem]] = []

        do {
            for try await items in sut.execute() {
                emissions.append(items)
            }
            XCTFail("Expected an error")
        } catch {
            XCTAssertEqual(error as? TestError, TestError())
        }
        XCTAssertEqual(emissions, [cached])
    }

    private func collect(_ stream: AsyncThrowingStream<[CatalogItem], Error>) async throws -> [[CatalogItem]] {
        var emissions: [[CatalogItem]] = []
        for try await items in stream {
            emissions.append(items)
        }
        return emissions
    }
}
