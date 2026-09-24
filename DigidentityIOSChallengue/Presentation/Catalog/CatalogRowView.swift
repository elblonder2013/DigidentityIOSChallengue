//
//  CatalogRowView.swift
//  DigidentityIOSChallengue
//
//  Created by Alexei on 24/09/2026.
//

import SwiftUI

struct CatalogRowView: View {
    let item: CatalogItemViewData

    @ScaledMetric(relativeTo: .headline) private var thumbnailSize: CGFloat = 72

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RemoteImageView(url: item.imageURL)
                .frame(width: thumbnailSize, height: thumbnailSize)
                .clipShape(.rect(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.description)
                    .font(.headline)
                    .lineLimit(2)

                Text("ID: \(item.id)")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)

                Label("Confidence \(item.confidenceText)", systemImage: "gauge.medium")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    List {
        CatalogRowView(item: CatalogItemViewData(item: CatalogItem(
            id: "6915a62ede391",
            imageURL: URL(string: "https://placehold.co/512x512?text=30.%20rbgvb")!,
            description: "30. rbgvb",
            confidence: 0.96
        )))
    }
}
