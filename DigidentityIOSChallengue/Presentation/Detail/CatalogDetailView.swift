//
//  CatalogDetailView.swift
//  DigidentityIOSChallengue
//
//  Created by Alexei on 24/09/2026.
//

import SwiftUI

struct CatalogDetailView: View {
    let item: CatalogItemViewData

    @Environment(\.verticalSizeClass) private var verticalSizeClass

    /// Landscape on iPhone: image and details side by side instead of stacked.
    private var isSideBySide: Bool { verticalSizeClass == .compact }

    var body: some View {
        ScrollView {
            let layout = isSideBySide
                ? AnyLayout(HStackLayout(alignment: .top, spacing: 24))
                : AnyLayout(VStackLayout(alignment: .leading, spacing: 24))

            layout {
                if isSideBySide {
                    image.containerRelativeFrame(.horizontal, count: 5, span: 2, spacing: 24)
                } else {
                    // Keeps the image a sensible size on wide screens such as iPad.
                    image
                        .frame(maxWidth: 600)
                        .frame(maxWidth: .infinity)
                }
                details
            }
            .padding()
        }
        .navigationTitle("Item")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var image: some View {
        RemoteImageView(url: item.imageURL)
            .aspectRatio(1, contentMode: .fit)
            .clipShape(.rect(cornerRadius: 12))
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(item.description)
                .font(.title2.bold())

            LabeledContent("ID") {
                Text(item.id)
                    .font(.body.monospaced())
                    .textSelection(.enabled)
            }

            LabeledContent("Confidence", value: item.confidenceText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        CatalogDetailView(item: CatalogItemViewData(item: CatalogItem(
            id: "6915a62ede391",
            imageURL: URL(string: "https://placehold.co/512x512?text=30.%20rbgvb")!,
            description: "30. rbgvb",
            confidence: 0.96
        )))
    }
}
