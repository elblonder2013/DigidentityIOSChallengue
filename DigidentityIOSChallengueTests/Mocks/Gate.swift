//
//  Gate.swift
//  DigidentityIOSChallengueTests
//
//  Created by Alexei on 24/09/2026.
//

import Foundation

/// Suspends callers of `wait()` until `open()` is called, to observe work that is still in flight.
final class Gate: Sendable {
    private let stream: AsyncStream<Void>
    private let continuation: AsyncStream<Void>.Continuation

    init() {
        (stream, continuation) = AsyncStream.makeStream()
    }

    func wait() async {
        for await _ in stream { return }
    }

    func open() {
        continuation.finish()
    }
}
