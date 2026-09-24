//
//  DefaultAPIClientTests.swift
//  DigidentityIOSChallengueTests
//
//  Created by Alexei on 24/09/2026.
//

import XCTest
@testable import DigidentityIOSChallengue

final class DefaultAPIClientTests: XCTestCase {
    private struct Payload: Decodable, Equatable {
        let value: String
    }

    private let baseURL = URL(string: "https://api.example.com")!
    private var sut: DefaultAPIClient!

    override func setUp() {
        super.setUp()
        let config = NetworkConfig(baseURL: baseURL, headers: ["Authorization": "token-123"])
        sut = DefaultAPIClient(config: config, session: URLProtocolStub.makeSession())
    }

    override func tearDown() {
        URLProtocolStub.handler = nil
        sut = nil
        super.tearDown()
    }

    func test_request_buildsURLMethodAndHeaders() async throws {
        let recorder = RequestRecorder()
        URLProtocolStub.handler = { request in
            recorder.record(request)
            return (Self.response(for: request, status: 200), Data(#"{"value":"ok"}"#.utf8))
        }
        let endpoint = Endpoint<Payload>(path: "v1/items", queryItems: [URLQueryItem(name: "max_id", value: "abc")])

        _ = try await sut.request(endpoint)

        let request = try XCTUnwrap(recorder.request)
        XCTAssertEqual(request.url?.absoluteString, "https://api.example.com/v1/items?max_id=abc")
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "token-123")
    }

    func test_request_withoutQueryItems_buildsURLWithoutQuery() async throws {
        let recorder = RequestRecorder()
        URLProtocolStub.handler = { request in
            recorder.record(request)
            return (Self.response(for: request, status: 200), Data(#"{"value":"ok"}"#.utf8))
        }

        _ = try await sut.request(Endpoint<Payload>(path: "v1/items"))

        XCTAssertEqual(recorder.request?.url?.absoluteString, "https://api.example.com/v1/items")
    }

    func test_request_onSuccess_decodesResponse() async throws {
        URLProtocolStub.handler = { request in
            (Self.response(for: request, status: 200), Data(#"{"value":"ok"}"#.utf8))
        }

        let payload = try await sut.request(Endpoint<Payload>(path: "v1/items"))

        XCTAssertEqual(payload, Payload(value: "ok"))
    }

    func test_request_onNon2xxStatus_throwsHTTPStatusError() async {
        URLProtocolStub.handler = { request in
            (Self.response(for: request, status: 401), Data())
        }

        await assertThrowsNetworkError { error in
            guard case .httpStatus(401) = error else { return XCTFail("Unexpected error: \(error)") }
        }
    }

    func test_request_onInvalidBody_throwsDecodingError() async {
        URLProtocolStub.handler = { request in
            (Self.response(for: request, status: 200), Data("not json".utf8))
        }

        await assertThrowsNetworkError { error in
            guard case .decoding = error else { return XCTFail("Unexpected error: \(error)") }
        }
    }

    func test_request_onConnectionFailure_throwsTransportError() async {
        URLProtocolStub.handler = { _ in throw URLError(.notConnectedToInternet) }

        await assertThrowsNetworkError { error in
            guard case .transport(let urlError) = error, urlError.code == .notConnectedToInternet else {
                return XCTFail("Unexpected error: \(error)")
            }
        }
    }

    // MARK: - Helpers

    private func assertThrowsNetworkError(
        file: StaticString = #filePath,
        line: UInt = #line,
        _ verify: (NetworkError) -> Void
    ) async {
        do {
            _ = try await sut.request(Endpoint<Payload>(path: "v1/items"))
            XCTFail("Expected an error", file: file, line: line)
        } catch let error as NetworkError {
            verify(error)
        } catch {
            XCTFail("Expected NetworkError, got \(error)", file: file, line: line)
        }
    }

    private static func response(for request: URLRequest, status: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!
    }
}

/// Captures the request seen by `URLProtocolStub`, which runs on a URL loading thread.
private final class RequestRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var recorded: URLRequest?

    var request: URLRequest? { lock.withLock { recorded } }

    func record(_ request: URLRequest) {
        lock.withLock { recorded = request }
    }
}
