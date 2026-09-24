//
//  CatalogApp.swift
//  DigidentityIOSChallengue
//
//  Created by Alexei on 23/09/2026.
//

import SwiftUI

@main
struct CatalogApp: App {
    /// Unit tests run inside the app, which must then stay idle: no network calls and no writes to the real store.
    private static let isRunningUnitTests = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil

    /// Created once, so re-evaluating `body` never rebuilds the feature.
    @State private var catalogViewModel: CatalogViewModel?

    init() {
        guard !Self.isRunningUnitTests else { return }
        let catalogScene = AppDIContainer().makeCatalogSceneDIContainer()
        _catalogViewModel = State(initialValue: catalogScene.makeCatalogViewModel())
    }

    var body: some Scene {
        WindowGroup {
            if let catalogViewModel {
                CatalogView(viewModel: catalogViewModel)
            }
        }
    }
}
