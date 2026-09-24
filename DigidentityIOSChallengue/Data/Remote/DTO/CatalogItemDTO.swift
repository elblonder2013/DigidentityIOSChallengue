//
//  CatalogItemDTO.swift
//  DigidentityIOSChallengue
//
//  Created by Alexei on 24/09/2026.
//

import Foundation

struct CatalogItemDTO: Decodable, Equatable, Sendable {
    let id: String
    let text: String
    let image: String
    let confidence: Double

    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case text
        case image
        case confidence
    }
}

extension CatalogItemDTO {
    /// Returns `nil` when the image URL is not valid, so one malformed item does not fail a whole page.
    func toDomain() -> CatalogItem? {
        guard let imageURL = URL(string: image) else { return nil }
        return CatalogItem(id: id, imageURL: imageURL, description: text, confidence: confidence)
    }
}
