//
//  RenderableImageURL.swift
//  DigidentityIOSChallengue
//
//  Created by Alexei on 24/09/2026.
//

import Foundation

/// placehold.co serves SVG unless a raster format is part of the path, and iOS image views cannot decode SVG.
/// Asks for the PNG variant instead. URLs from other hosts are returned unchanged.
enum RenderableImageURL {
    static func make(from url: URL) -> URL {
        guard url.host() == "placehold.co",
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.path.split(separator: "/").count == 1 else {
            return url
        }
        components.path += "/png"
        return components.url ?? url
    }
}
