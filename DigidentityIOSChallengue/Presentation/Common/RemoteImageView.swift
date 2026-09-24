//
//  RemoteImageView.swift
//  DigidentityIOSChallengue
//
//  Created by Alexei on 24/09/2026.
//

import SwiftUI

/// Loads an image from the network, filling the space it is given.
struct RemoteImageView: View {
    let url: URL

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                placeholder {
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            case .empty:
                placeholder { ProgressView() }
            @unknown default:
                placeholder { EmptyView() }
            }
        }
        .accessibilityHidden(true)
    }

    private func placeholder(@ViewBuilder content: () -> some View) -> some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.quaternary)
    }
}
