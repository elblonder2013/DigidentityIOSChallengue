//
//  NetworkError.swift
//  DigidentityIOSChallengue
//
//  Created by Alexei on 24/09/2026.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case transport(URLError)
    case invalidResponse
    case httpStatus(Int)
    case decoding(Error)
}
