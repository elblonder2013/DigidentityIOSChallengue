//
//  CatalogItemDTOTests.swift
//  DigidentityIOSChallengueTests
//
//  Created by Alexei on 24/09/2026.
//

import XCTest
@testable import DigidentityIOSChallengue

final class CatalogItemDTOTests: XCTestCase {
    func test_decode_mapsAPIFieldNames() throws {
        let json = Data("""
        {
            "text": "30. rbgvb",
            "confidence": 0.96,
            "image": "https://placehold.co/512x512?text=30.%20rbgvb",
            "_id": "6915a62ede391"
        }
        """.utf8)

        let dto = try JSONDecoder().decode(CatalogItemDTO.self, from: json)

        XCTAssertEqual(dto, CatalogItemDTO(
            id: "6915a62ede391",
            text: "30. rbgvb",
            image: "https://placehold.co/512x512?text=30.%20rbgvb",
            confidence: 0.96
        ))
    }

    func test_toDomain_mapsAllFields() {
        let dto = CatalogItemDTO(id: "abc", text: "A photo", image: "https://example.com/a.png", confidence: 0.4)

        XCTAssertEqual(dto.toDomain(), CatalogItem(
            id: "abc",
            imageURL: URL(string: "https://example.com/a.png")!,
            description: "A photo",
            confidence: 0.4
        ))
    }

    func test_toDomain_withInvalidImageURL_returnsNil() {
        let dto = CatalogItemDTO(id: "abc", text: "A photo", image: "", confidence: 0.4)

        XCTAssertNil(dto.toDomain())
    }
}
