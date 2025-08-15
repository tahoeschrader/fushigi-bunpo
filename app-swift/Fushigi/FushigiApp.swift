//
//  FushigiApp.swift
//  Fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import SwiftData
import SwiftUI

@main
struct FushigiApp: App {
    // MARK: - Shared Container

    /// The shared SwiftData container used by the app.
    /// Uses a persistent store (not in-memory) so data persists across launches.
    var sharedModelContainer: ModelContainer = {
        // Delete the store when testing since store is in flux
        #if DEBUG
            if let appSupportURL = FileManager.default
                .urls(for: .applicationSupportDirectory, in: .userDomainMask)
                .first
            {
                let storeURL = appSupportURL.appendingPathComponent("default.store")
                try? FileManager.default.removeItem(at: storeURL)
            }
        #endif
        let schema = Schema([GrammarPointModel.self])
        // For a real app, we don't want the data store to only live in memory
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - Stores

    /// The main GrammarStore used throughout the app.
    /// Initialized with the shared SwiftData container's main context.
    @StateObject private var grammarStore: GrammarStore

    // TODO: Add Journal, Tags, Settings, Etc.

    // MARK: - Initialize Data Storage

    init() {
        let context = sharedModelContainer.mainContext
        _grammarStore = StateObject(wrappedValue: GrammarStore(modelContext: context))
    }

    // MARK: - App Body

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(grammarStore)
                .task {
                    // Load local SwiftData objects
                    await grammarStore.loadLocal()
                    // Then sync with remote PostgreSQL
                    await grammarStore.syncWithRemote()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .withPreviewGrammarStore()
}
