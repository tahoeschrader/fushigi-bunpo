//
//  FushigiApp.swift
//  Fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import SwiftData
import SwiftUI
import TipKit

// MARK: - Fushigi App

/// Main app entry point for Fushigi language learning app
@main
struct FushigiApp: App {
    // MARK: - Shared Container

    /// Shared SwiftData container for persistent storage
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GrammarPointLocal.self,
            JournalEntryLocal.self,
            // TagModel.self,
            // SettingsModel.self
        ])

        // For a real app, the data store should not only live in memory
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - Stores and Init

    /// Grammar store for user grammars, daily random, and SRS
    @StateObject private var grammarStore: GrammarStore

    /// Grammar store for user grammars, daily random, and SRS
    @StateObject private var journalStore: JournalStore

    // Journal store of all user journal entries
    // @StateObject private var journalStore: JournalStore

    // Tag store of all user created tags linking journal entry sentencies to grammar points
    // @StateObject private var tagStore: TagStore

    // Settings store of all user settings
    // @StateObject private var settingsStore: SettingsStore

    /// Initialize app data stores
    init() {
        #if DEBUG
            wipeSwiftData(container: sharedModelContainer)
        #endif

        let context = sharedModelContainer.mainContext
        _grammarStore = StateObject(wrappedValue: GrammarStore(modelContext: context))
        _journalStore = StateObject(wrappedValue: JournalStore(modelContext: context))
        // _tagStore = StateObject(wrappedValue: TagStore(modelContext: context))
        // _settingsStore = StateObject(wrappedValue: SettingsStore(modelContext: context))
    }

    /// Configure TipKit for user onboarding
    func configureTips() async {
        do {
            try Tips.configure([
                // .cloudKitContainer(.named("iCloud.com.apple.Fushigi.tips")),
                .displayFrequency(.immediate),
            ])
        } catch {
            print("Unable to configure tips: \(error)")
        }
    }

    // MARK: - App Body

    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(.mint)
                .environmentObject(grammarStore)
                .environmentObject(journalStore)
                // .environmentObject(tagStore)
                // .environmentObject(settingsStore)
                .task {
                    await configureTips()
                    await grammarStore.loadLocal()
                    await grammarStore.syncWithRemote()
                    grammarStore.updateRandomGrammarPoints()
                    await grammarStore.updateAlgorithmicGrammarPoints()
                    await journalStore.loadLocal()
                    await journalStore.syncWithRemote()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Debug Data Wipe

/// Wipe all data from persistent storage for debug mode
@MainActor
func wipeSwiftData(container: ModelContainer) {
    let context = container.mainContext

    do {
        try Tips.resetDatastore()
        try context.delete(model: GrammarPointLocal.self)
        try context.delete(model: JournalEntryLocal.self)
        // try context.delete(model: TagModel.self)
        // try context.delete(model: SettingsModel.self)

        try context.save()
        print("SwiftData store wiped successfully")
    } catch {
        print("Failed to wipe SwiftData: \(error)")
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .withPreviewStores()
}
