//
//  PreviewHelper.swift
//  Fushigi
//
//  Created by Tahoe Schrader on 2025/08/14.
//  Utilized AI to figure out how to do this. Not sure how to improve/simplify.
//

import SwiftData
import SwiftUI

// MARK: - Preview Helper

/// Error states for preview configuration
enum PreviewError: LocalizedError {
    case normal
    case emptyData
    case syncError
    case loadError
    case networkTimeout
    case postgresConnectionError

    /// User-friendly description of each preview mode
    var description: String {
        switch self {
        case .normal:
            "Standard operation with full sample data set"
        case .emptyData:
            "No data available, first-time user experience"
        case .syncError:
            "General synchronization failure with remote services"
        case .loadError:
            "Database corruption or loading failure scenario"
        case .networkTimeout:
            "Network connectivity issues preventing data access"
        case .postgresConnectionError:
            "PostgreSQL database connection failure scenario"
        }
    }

    /// User-friendly description of each failure reason
    var failureReason: String? {
        switch self {
        case .syncError:
            "The remote server is not responding"
        case .loadError:
            "Local database file appears to be damaged"
        case .networkTimeout:
            "Request took too long to complete"
        case .postgresConnectionError:
            "Unable to establish connection to PostgreSQL database"
        case .normal:
            "No issues"
        case .emptyData:
            "All data has been filtered out or there is no data to filter"
        }
    }
}

/// Preview helper for configuring different app states
enum PreviewHelper {
    case normal
    case emptyData
    case syncError
    case loadError
    case networkTimeout
    case postgresConnectionError
}

extension PreviewHelper {
    /// Create fake data store for Preview mode with various configurations
    @MainActor
    static func withStore(
        mode: PreviewHelper = .normal,
        @ViewBuilder content: @escaping (GrammarStore) -> some View,
    ) -> some View {
        do {
            // for previews, we only want the data store to only live in memory while testing
            let container = try ModelContainer(
                for: Schema([GrammarPointModel.self]),
                configurations: [ModelConfiguration(isStoredInMemoryOnly: true)],
            )
            let store = GrammarStore(modelContext: container.mainContext)

            // Configure store with fake data based on preview mode
            configureStoreForPreviewMode(store: store, mode: mode)

            return AnyView(
                content(store)
                    .environmentObject(store)
                    .modelContainer(container),
            )
        } catch {
            return AnyView(
                Text("Preview Error: \(error.localizedDescription)")
                    .foregroundColor(.red),
            )
        }
    }

    /// Configure store for different preview modes
    @MainActor
    private static func configureStoreForPreviewMode(store: GrammarStore, mode: PreviewHelper) {
        switch mode {
        case .normal:
            setupNormalPreviewData(store: store)

        case .emptyData:
            store.grammarItems = []

        case .syncError:
            setupNormalPreviewData(store: store)
            store.syncError = PreviewError.syncError

        case .loadError:
            setupNormalPreviewData(store: store)
            store.syncError = PreviewError.loadError

        case .networkTimeout:
            setupNormalPreviewData(store: store)
            store.isSyncing = true
            store.syncError = PreviewError.networkTimeout

        case .postgresConnectionError:
            setupNormalPreviewData(store: store)
            store.syncError = PreviewError.postgresConnectionError
        }
    }

    /// Load preview store with fake grammar data
    @MainActor
    private static func setupNormalPreviewData(store: GrammarStore) {
        let fakeItems = [
            GrammarPointModel(id: UUID(), context: "casual", usage: "Hello", meaning: "こんにちは", tags: ["greeting"]),
            GrammarPointModel(id: UUID(), context: "casual", usage: "Goodbye", meaning: "さようなら", tags: ["farewell"]),
            GrammarPointModel(id: UUID(), context: "casual", usage: "I", meaning: "私は", tags: ["context"]),
            GrammarPointModel(id: UUID(), context: "casual", usage: "Cool", meaning: "かっこいい", tags: ["adjective"]),
            GrammarPointModel(id: UUID(), context: "casual", usage: "Am", meaning: "desu", tags: ["sentence-ender"]),
        ]

        store.grammarItems = fakeItems
        store.setRandomGrammarPointsForPreview(Array(fakeItems.shuffled().prefix(5)))
        store.setAlgorithmicGrammarPointsForPreview(Array(fakeItems.shuffled().prefix(5)))
    }
}
