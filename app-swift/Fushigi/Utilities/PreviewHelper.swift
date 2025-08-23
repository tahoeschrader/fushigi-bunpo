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

/// Current state of database health or error mode
enum DataState {
    case normal
    case emptyData
    case syncError
    case networkLoading
    case postgresConnectionError

    /// Error states for preview configuration
    enum Health: LocalizedError {
        case normal
        case emptyData
        case syncError
        case networkLoading
        case postgresConnectionError

        /// User-friendly description of each preview mode
        var description: String {
            switch self {
            case .normal:
                "Standard operation with full sample data set"
            case .emptyData:
                "No data available, no matches against filter, first-time user experience, or bug wipe"
            case .syncError:
                "General synchronization failure with remote or local services"
            case .networkLoading:
                "Currently loading local data and fetching from PostgreSQL"
            case .postgresConnectionError:
                "Unable to establish connection to PostgreSQL database"
            }
        }
    }
}

enum PreviewHelper {
    /// Create fake data store for Preview mode with various configurations
    @MainActor
    static func withStore(
        mode: DataState = .normal,
        @ViewBuilder content: @escaping (GrammarStore) -> some View,
    ) -> some View {
        do {
            // for previews, we only want the data store to only live in memory while testing
            let container = try ModelContainer(
                for: Schema([GrammarPointLocal.self]),
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
    private static func configureStoreForPreviewMode(store: GrammarStore, mode: DataState) {
        switch mode {
        case .normal:
            setupNormalPreviewData(store: store)

        case .emptyData:
            store.grammarItems = []

        case .syncError:
            setupNormalPreviewData(store: store)
            store.syncError = DataState.Health.syncError

        case .networkLoading:
            setupNormalPreviewData(store: store)
            store.isSyncing = true

        case .postgresConnectionError:
            setupNormalPreviewData(store: store)
            store.syncError = DataState.Health.postgresConnectionError
        }
    }

    /// Load preview store with fake grammar data
    @MainActor
    private static func setupNormalPreviewData(store: GrammarStore) {
        let fakeItems = [
            GrammarPointLocal(id: UUID(), context: "casual", usage: "Hello", meaning: "こんにちは", tags: ["greeting"]),
            GrammarPointLocal(id: UUID(), context: "casual", usage: "Goodbye", meaning: "さようなら", tags: ["farewell"]),
            GrammarPointLocal(id: UUID(), context: "casual", usage: "I", meaning: "私は", tags: ["context"]),
            GrammarPointLocal(id: UUID(), context: "casual", usage: "Cool", meaning: "かっこいい", tags: ["adjective"]),
            GrammarPointLocal(id: UUID(), context: "casual", usage: "Am", meaning: "desu", tags: ["sentence-ender"]),
        ]

        store.grammarItems = fakeItems
        store.setRandomGrammarPointsForPreview(Array(fakeItems.shuffled().prefix(5)))
        store.setAlgorithmicGrammarPointsForPreview(Array(fakeItems.shuffled().prefix(5)))
    }
}
