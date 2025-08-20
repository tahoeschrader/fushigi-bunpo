//
//  FushigiApp.swift
//  Fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import SwiftData
import SwiftUI
import TipKit

@main
struct FushigiApp: App {
    // MARK: - Shared Container

    /// The shared SwiftData container which uses a persistent store (not in-memory) so data persists across launches
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GrammarPointModel.self,
            // JournalModel.self,
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

    // MARK: - Stores

    /// Grammar store of all user grammars, daily random, and daily SRS
    @StateObject private var grammarStore: GrammarStore

    /// Journal store of all user journal entries
    // @StateObject private var journalStore: JournalStore

    /// Tag store of all user created tags linking journal entry sentencies to grammar points
    // @StateObject private var tagStore: TagStore

    /// Settings store of all user settings
    // @StateObject private var settingsStore: SettingsStore

    /// Boilerplate to initialize multi platform app data stored on device
    init() {
        #if DEBUG
            wipeSwiftData(container: sharedModelContainer)
        #endif

        let context = sharedModelContainer.mainContext
        _grammarStore = StateObject(wrappedValue: GrammarStore(modelContext: context))
        // _journalStore = StateObject(wrappedValue: JournalStore(modelContext: context))
        // _tagStore = StateObject(wrappedValue: TagStore(modelContext: context))
        // _settingsStore = StateObject(wrappedValue: SettingsStore(modelContext: context))
    }

    /// Boilerplate to initialize tips showing users how to use the app
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
                .environmentObject(grammarStore)
                // .environmentObject(journalStore)
                // .environmentObject(tagStore)
                // .environmentObject(settingsStore)
                .task {
                    await configureTips()
                    await grammarStore.loadLocal() // SwiftData objects
                    await grammarStore.syncWithRemote() // PostgreSQL

                    // make sure the grammar point subsets are checked for updates on startup too
                    grammarStore.updateRandomGrammarPoints()
                    await grammarStore.updateAlgorithmicGrammarPoints()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Debug Data Wipe

/// Wipe all data from persistent storage at startup for Preview/Debug mode.
///
/// This is necessary when running the app to prevent corruption of the actual database. We don't
/// want the database filling up and persisting data when testing out the UI in the Simulator, Preview window,
/// or on a physical device. This simply just loops through each store, deletes all data, and saves. This is better
/// than physically deleting the SQLite database every time you want to try something new.
@MainActor
func wipeSwiftData(container: ModelContainer) {
    let context = container.mainContext

    do {
        try Tips.resetDatastore()
        try context.delete(model: GrammarPointModel.self)
        // try context.delete(model: JournalModel.self)
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
        .withPreviewGrammarStore()
}
