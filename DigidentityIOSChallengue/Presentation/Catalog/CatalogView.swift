//
//  CatalogView.swift
//  DigidentityIOSChallengue
//
//  Created by Alexei on 24/09/2026.
//

import SwiftUI

struct CatalogView: View {
    @State private var viewModel: CatalogViewModel

    init(viewModel: CatalogViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Catalog")
                .navigationDestination(for: CatalogItemViewData.self) { item in
                    CatalogDetailView(item: item)
                }
        }
        .task { await viewModel.onAppear() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading catalog…")
        case .empty:
            ContentUnavailableView {
                Label("No Items", systemImage: "photo.on.rectangle")
            } description: {
                Text("The catalog is empty.")
            } actions: {
                Button("Reload") { Task { await viewModel.retry() } }
            }
        case .failed(let message):
            ContentUnavailableView {
                Label("Unable to Load", systemImage: "wifi.exclamationmark")
            } description: {
                Text(message)
            } actions: {
                Button("Retry") { Task { await viewModel.retry() } }
                    .buttonStyle(.borderedProminent)
            }
        case .loaded:
            itemList
        }
    }

    private var itemList: some View {
        List {
            ForEach(viewModel.items) { item in
                NavigationLink(value: item) {
                    CatalogRowView(item: item)
                }
                .onAppear {
                    Task { await viewModel.loadMoreIfNeeded(currentItem: item) }
                }
            }
            paginationFooter
        }
        .listStyle(.plain)
        .refreshable { await viewModel.refresh() }
        .safeAreaInset(edge: .bottom) {
            if let message = viewModel.errorMessage {
                ErrorBanner(message: message) { viewModel.errorMessage = nil }
            }
        }
        .animation(.default, value: viewModel.errorMessage)
    }

    @ViewBuilder
    private var paginationFooter: some View {
        switch viewModel.paginationState {
        case .idle:
            EmptyView()
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden)
        case .failed:
            Button {
                Task { await viewModel.loadMore() }
            } label: {
                Label("Couldn't load more items. Tap to retry.", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .listRowSeparator(.hidden)
        case .finished:
            Text("You've reached the end of the catalog.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden)
        }
    }
}

private struct ErrorBanner: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text(message)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button("Dismiss", systemImage: "xmark", action: onDismiss)
                .labelStyle(.iconOnly)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 12))
        .padding(.horizontal)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
