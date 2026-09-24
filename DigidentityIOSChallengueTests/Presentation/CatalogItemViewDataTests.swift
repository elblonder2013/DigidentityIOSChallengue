//
//  CatalogItemViewDataTests.swift
//  DigidentityIOSChallengueTests
//
//  Created by Alexei on 24/09/2026.
//

import XCTest
@testable import DigidentityIOSChallengue

final class CatalogItemViewDataTests: XCTestCase {
    func test_init_mapsAllFieldsAndFormatsConfidenceAsPercentage() {
        let item = CatalogItem.stub(
            id: "6915a62ede391",
            imageURL: URL(string: "https://example.com/a.png")!,
            description: "30. rbgvb",
            confidence: 0.96
        )

        let viewData = CatalogItemViewData(item: item, locale: Locale(identifier: "en_US"))

        XCTAssertEqual(viewData.id, "6915a62ede391")
        XCTAssertEqual(viewData.imageURL, URL(string: "https://example.com/a.png")!)
        XCTAssertEqual(viewData.description, "30. rbgvb")
        XCTAssertEqual(viewData.confidenceText, "96%")
    }

    func test_init_roundsConfidenceToWholePercent() {
        let viewData = CatalogItemViewData(item: .stub(confidence: 0.075), locale: Locale(identifier: "en_US"))

        XCTAssertEqual(viewData.confidenceText, "8%")
    }
}
