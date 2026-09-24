//
//  AppConfiguration.swift
//  DigidentityIOSChallengue
//
//  Created by Alexei on 24/09/2026.
//

import Foundation

/// Values injected at build time from `Config/App.xcconfig` and `Config/Secrets.xcconfig` via Info.plist.
struct AppConfiguration: Sendable {
    let apiBaseURL: URL
    let apiToken: String

    init(bundle: Bundle = .main) {
        guard let baseURLString = bundle.object(forInfoDictionaryKey: "APIBaseURL") as? String,
              let baseURL = URL(string: baseURLString) else {
            fatalError("APIBaseURL is missing or invalid in Info.plist. Check Config/App.xcconfig.")
        }
        let token = bundle.object(forInfoDictionaryKey: "APIToken") as? String ?? ""
        assert(!token.isEmpty, "APIToken is empty. Copy Config/Secrets.example.xcconfig to Config/Secrets.xcconfig.")

        self.apiBaseURL = baseURL
        self.apiToken = token
    }
}
