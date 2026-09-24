//
//  CatalogItem+Stub.swift
//  DigidentityIOSChallengueTests
//
//  Created by Alexei on 24/09/2026.
//

import Foundation
@testable import DigidentityIOSChallengue

extension CatalogItem {
    static func stub(
        id: String = "1",
        imageURL: URL = URL(string: "https://example.com/1.png")!,
        description: String = "Item",
        confidence: Double = 0.5
    ) -> CatalogItem {
        CatalogItem(id: id, imageURL: imageURL, description: description, confidence: confidence)
    }
}

struct TestError: Error, Equatable {}

extension CatalogItemDTO {
    static func stub(id: String, text: String = "Item", confidence: Double = 0.5) -> CatalogItemDTO {
        CatalogItemDTO(id: id, text: text, image: "https://example.com/\(id).png", confidence: confidence)
    }
}
