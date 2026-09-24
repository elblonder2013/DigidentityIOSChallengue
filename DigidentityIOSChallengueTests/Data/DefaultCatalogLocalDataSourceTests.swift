//
//  DefaultCatalogLocalDataSourceTests.swift
//  DigidentityIOSChallengueTests
//
//  Created by Alexei on 24/09/2026.
//

import SwiftData
import XCTest
@testable import DigidentityIOSChallengue

final class DefaultCatalogLocalDataSourceTests: XCTestCase {
    private var container: ModelContainer!
    private var sut: DefaultCatalogLocalDataSource!

    override func setUpWithError() throws {
        try super.setUpWithError()
        container = try ModelContainer(
            for: CatalogItemEntity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        sut = DefaultCatalogLocalDataSource(modelContainer: container)
    }

    override func tearDown() {
        sut = nil
        container = nil
        super.tearDown()
    }

    func test_items_whenEmpty_returnsNoItems() async throws {
        let items = try await sut.items()

        XCTAssertEqual(items, [])
    }

    func test_save_thenItems_returnsItemsNewestFirst() async throws {
        let older = CatalogItem.stub(id: "6915a62e82709", description: "1. older")
        let newer = CatalogItem.stub(id: "6915a62ede391", description: "30. newer")

        try await sut.save([older, newer])
        let items = try await sut.items()

        XCTAssertEqual(items, [newer, older])
    }

    func test_save_withExistingID_updatesInsteadOfDuplicating() async throws {
        try await sut.save([.stub(id: "1", description: "Old", confidence: 0.1)])
        let updated = CatalogItem.stub(id: "1", description: "New", confidence: 0.9)

        try await sut.save([updated])
        let items = try await sut.items()

        XCTAssertEqual(items, [updated])
    }

    func test_save_appendsToPreviouslySavedItems() async throws {
        try await sut.save([.stub(id: "3"), .stub(id: "2")])

        try await sut.save([.stub(id: "1")])
        let items = try await sut.items()

        XCTAssertEqual(items.map(\.id), ["3", "2", "1"])
    }

    func test_items_areVisibleToAnotherDataSourceSharingTheContainer() async throws {
        try await sut.save([.stub(id: "1")])

        let otherInstance = DefaultCatalogLocalDataSource(modelContainer: container)
        let items = try await otherInstance.items()

        XCTAssertEqual(items.map(\.id), ["1"])
    }
}
