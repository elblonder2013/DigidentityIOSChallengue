//
//  DefaultCatalogRemoteDataSourceTests.swift
//  DigidentityIOSChallengueTests
//
//  Created by Alexei on 24/09/2026.
//

import XCTest
@testable import DigidentityIOSChallengue

final class DefaultCatalogRemoteDataSourceTests: XCTestCase {
    private var apiClient: APIClientMock!
    private var sut: DefaultCatalogRemoteDataSource!

    override func setUp() {
        super.setUp()
        apiClient = APIClientMock()
        sut = DefaultCatalogRemoteDataSource(apiClient: apiClient)
    }

    override func tearDown() {
        sut = nil
        apiClient = nil
        super.tearDown()
    }

    func test_fetchItems_withoutIDs_requestsItemsWithoutQuery() async throws {
        _ = try await sut.fetchItems(sinceID: nil, maxID: nil)

        XCTAssertEqual(apiClient.requestedEndpoints, [.init(path: "v1/items", method: .get, queryItems: [])])
    }

    func test_fetchItems_withMaxID_sendsMaxIDQuery() async throws {
        _ = try await sut.fetchItems(sinceID: nil, maxID: "abc")

        XCTAssertEqual(apiClient.requestedEndpoints.first?.queryItems, [URLQueryItem(name: "max_id", value: "abc")])
    }

    func test_fetchItems_withSinceID_sendsSinceIDQuery() async throws {
        _ = try await sut.fetchItems(sinceID: "abc", maxID: nil)

        XCTAssertEqual(apiClient.requestedEndpoints.first?.queryItems, [URLQueryItem(name: "since_id", value: "abc")])
    }

    func test_fetchItems_returnsDecodedItems() async throws {
        apiClient.result = .success(Data("""
        [
            { "_id": "2", "text": "Two", "image": "https://example.com/2.png", "confidence": 0.2 },
            { "_id": "1", "text": "One", "image": "https://example.com/1.png", "confidence": 0.1 }
        ]
        """.utf8))

        let items = try await sut.fetchItems(sinceID: nil, maxID: nil)

        XCTAssertEqual(items.map(\.id), ["2", "1"])
    }

    func test_fetchItems_propagatesClientError() async {
        apiClient.result = .failure(NetworkError.httpStatus(401))

        do {
            _ = try await sut.fetchItems(sinceID: nil, maxID: nil)
            XCTFail("Expected an error")
        } catch {
            guard case NetworkError.httpStatus(401) = error else { return XCTFail("Unexpected error: \(error)") }
        }
    }
}
