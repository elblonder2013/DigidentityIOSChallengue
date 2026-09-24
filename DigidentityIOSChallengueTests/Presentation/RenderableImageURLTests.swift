//
//  RenderableImageURLTests.swift
//  DigidentityIOSChallengueTests
//
//  Created by Alexei on 24/09/2026.
//

import XCTest
@testable import DigidentityIOSChallengue

final class RenderableImageURLTests: XCTestCase {
    func test_make_withPlaceholdImageWithoutFormat_requestsPNG() {
        let url = URL(string: "https://placehold.co/512x512?text=30.%20rbgvb")!

        XCTAssertEqual(
            RenderableImageURL.make(from: url).absoluteString,
            "https://placehold.co/512x512/png?text=30.%20rbgvb"
        )
    }

    func test_make_withPlaceholdImageWithFormat_keepsURL() {
        let url = URL(string: "https://placehold.co/512x512/jpg?text=a")!

        XCTAssertEqual(RenderableImageURL.make(from: url), url)
    }

    func test_make_withOtherHost_keepsURL() {
        let url = URL(string: "https://example.com/512x512?text=a")!

        XCTAssertEqual(RenderableImageURL.make(from: url), url)
    }
}
