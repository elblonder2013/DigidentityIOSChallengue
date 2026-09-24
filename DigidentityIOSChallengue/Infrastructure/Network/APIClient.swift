//
//  APIClient.swift
//  DigidentityIOSChallengue
//
//  Created by Alexei on 24/09/2026.
//

import Foundation

protocol APIClient: Sendable {
    /// Performs the request and decodes its body. Throws `NetworkError`, or `CancellationError` when cancelled.
    func request<Response: Decodable>(_ endpoint: Endpoint<Response>) async throws -> Response
}
