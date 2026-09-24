//
//  CatalogItemViewData.swift
//  DigidentityIOSChallengue
//
//  Created by Alexei on 24/09/2026.
//

import Foundation

struct CatalogItemViewData: Identifiable, Hashable, Sendable {
    let id: String
    let imageURL: URL
    let description: String
    /// Confidence as a percentage, e.g. "96%".
    let confidenceText: String

    init(item: CatalogItem, locale: Locale = .current) {
        id = item.id
        imageURL = RenderableImageURL.make(from: item.imageURL)
        description = item.description
        confidenceText = item.confidence.formatted(.percent.precision(.fractionLength(0)).locale(locale))
    }
}
