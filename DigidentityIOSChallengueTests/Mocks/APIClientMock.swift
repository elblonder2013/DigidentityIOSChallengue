//
//  APIClientMock.swift
//  DigidentityIOSChallengueTests
//
//  Created by Alexei on 24/09/2026.
//

import Foundation
@testable import DigidentityIOSChallengue

/// Decodes `responseData` into whatever the endpoint expects and records the requested endpoints.
/// Configured before use and read after the awaited call finishes, so it is never accessed concurrently.
final class APIClientMock: APIClient, @unchecked Sendable {
    struct RequestedEndpoint: Equatable {
        let path: String
        let method: HTTPMethod
        let queryItems: [URLQueryItem]
    }

    var result: Result<Data, Error> = .success(Data("[]".utf8))
    private(set) var requestedEndpoints: [RequestedEndpoint] = []

    func request<Response: Decodable>(_ endpoint: Endpoint<Response>) async throws -> Response {
        requestedEndpoints.append(RequestedEndpoint(path: endpoint.path, method: endpoint.method, queryItems: endpoint.queryItems))
        return try JSONDecoder().decode(Response.self, from: result.get())
    }
}
