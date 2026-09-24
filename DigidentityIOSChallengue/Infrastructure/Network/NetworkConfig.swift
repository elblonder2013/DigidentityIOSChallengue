//
//  NetworkConfig.swift
//  DigidentityIOSChallengue
//
//  Created by Alexei on 24/09/2026.
//

import Foundation

struct NetworkConfig: Sendable {
    let baseURL: URL
    /// Sent with every request, e.g. the `Authorization` header.
    let headers: [String: String]
}
