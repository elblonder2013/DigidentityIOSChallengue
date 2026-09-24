//
//  CatalogItem.swift
//  DigidentityIOSChallengue
//
//  Created by Alexei on 24/09/2026.
//

import Foundation

struct CatalogItem: Identifiable, Hashable, Sendable {
    let id: String
    let imageURL: URL
    let description: String
    let confidence: Double
}
