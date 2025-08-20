//
//  GrammarStore.swift
//  Fushigi
//
//  Created by Tahoe Schrader on 2025/08/14.
//

import Foundation
import SwiftData

@MainActor
class GrammarStore: ObservableObject {
    // in memory cache items for quick access by UI without needed to refetch
    @Published var grammarItems: [GrammarPointModel] = []
    @Published private(set) var randomGrammarItems: [GrammarPointModel] = []
    @Published private(set) var algorithmicGrammarItems: [GrammarPointModel] = []
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: Error?

    private var lastRandomUpdate: Date?
    private var lastAlgorithmicUpdate: Date?

    // modelContext: SwiftData database session or “scratchpad”
    // inserts only live in memory until saved
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - All Grammar

    /// Get all grammar points
    func getAllGrammarPoints() -> [GrammarPointModel] {
        grammarItems
    }

    /// Get specific grammar point by ID
    func getGrammarPoint(id: UUID?) -> GrammarPointModel? {
        getAllGrammarPoints().first { $0.id == id }
    }

    /// Search/filter grammar points
    func filterGrammarPoints(containing searchText: String? = nil) -> [GrammarPointModel] {
        var filtered = getAllGrammarPoints()

        if let searchText, !searchText.isEmpty {
            filtered = filtered.filter {
                $0.usage.localizedCaseInsensitiveContains(searchText) ||
                    $0.meaning.localizedCaseInsensitiveContains(searchText) ||
                    $0.context.localizedCaseInsensitiveContains(searchText) ||
                    $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }

        return filtered
    }

    // MARK: - Daily Grammar

    /// Get all random grammar points for the day
    func getRandomGrammarPoints() -> [GrammarPointModel] {
        randomGrammarItems
    }

    /// Get specific random grammar point by ID
    func getRandomGrammarPoint(id: UUID?) -> GrammarPointModel? {
        getRandomGrammarPoints().first { $0.id == id }
    }

    /// Get all SRS grammar points for the day
    func getAlgorithmicGrammarPoints() -> [GrammarPointModel] {
        algorithmicGrammarItems
    }

    /// Get specific SRS grammar point by ID
    func getAlgorithmicGrammarPoint(id: UUID?) -> GrammarPointModel? {
        getAlgorithmicGrammarPoints().first { $0.id == id }
    }

    // MARK: - Internal sync logic

    func loadLocal() async {
        do {
            grammarItems = try modelContext.fetch(FetchDescriptor<GrammarPointModel>())
            print("Loaded \(grammarItems.count) items from local storage")
        } catch {
            print("Failed to load local grammar points:", error)
        }
    }

    func syncWithRemote() async {
        // Proceed only if not already syncing, guarantee rest of code is safe
        guard !isSyncing else { return }

        isSyncing = true
        syncError = nil

        // End function by resetting sync flag, even after error
        defer { isSyncing = false }

        let result = await fetchGrammarPoints()
        switch result {
        case let .success(remotePoints):
            await processRemotePoints(remotePoints)
            lastSyncDate = Date()
        case let .failure(error):
            print("Failed to sync grammar points from PostgreSQL:", error)
            syncError = error
        }
    }

    private func processRemotePoints(_ remotePoints: [GrammarPoint]) async {
        for remote in remotePoints {
            // Check if exists locally by checking postgres id and swift id
            if let existing = grammarItems.first(where: { $0.id == remote.id }) {
                // Update existing
                existing.context = remote.context
                existing.usage = remote.usage
                existing.meaning = remote.meaning
                existing.tags = remote.tags
            } else {
                // Create new
                let newItem = GrammarPointModel(
                    id: remote.id,
                    context: remote.context,
                    usage: remote.usage,
                    meaning: remote.meaning,
                    tags: remote.tags,
                )
                modelContext.insert(newItem)
                grammarItems.append(newItem)
            }
        }

        // Save to commit to permanent SwiftData storage
        do {
            try modelContext.save()
            print("Synced \(remotePoints.count) local grammar points with PostgreSQL.")
            syncError = nil
        } catch {
            print("Failed to save to local SwiftData:", error)
            syncError = error
        }
    }

    /// Manual refresh (pull-to-refresh on scrollable views)
    func refresh() async {
        #if DEBUG
            print("Preview mode: refresh skipped.")
        #else
            // first check if there are new grammar points, then update subsets
            await syncWithRemote()
            updateRandomGrammarPoints()
            await updateAlgorithmicGrammarPoints()
        #endif
    }

    /// Calculate new subset of 5 random grammar points w/ ability to force by user -- TODO: add filtering
    func updateRandomGrammarPoints(force: Bool = false) {
        let today = Calendar.current.startOfDay(for: Date())
        if force || lastRandomUpdate != today || randomGrammarItems.isEmpty {
            randomGrammarItems = Array(grammarItems.shuffled().prefix(5))
            lastRandomUpdate = today
            print("Loaded \(randomGrammarItems.count) new random grammar items from SwiftData.")
        }
    }

    /// Calculate new subset of 5 SRS grammar points w/ ability to force by user
    func updateAlgorithmicGrammarPoints(force: Bool = false) async {
        let today = Calendar.current.startOfDay(for: Date())
        if force || lastAlgorithmicUpdate != today || algorithmicGrammarItems.isEmpty {
            // Proceed only if not already syncing, guarantee rest of code is safe
            guard !isSyncing else { return }

            isSyncing = true
            syncError = nil

            // End function by resetting sync flag, even after error
            defer { isSyncing = false }

            let result = await fetchGrammarPointsRandom()
            switch result {
            case let .success(points):
                let idSubset = Set(points.map(\.id))
                algorithmicGrammarItems = grammarItems.filter { idSubset.contains($0.id) }
                lastAlgorithmicUpdate = today
                print("Loaded \(algorithmicGrammarItems.count) SRS items from PostgreSQL.")
            case let .failure(error):
                syncError = error
                print("Failed to fetch SRS points:", error)
            }
        }
    }
}

// MARK: - Preview Helpers

/// Only for previews/testing
extension GrammarStore {
    func setRandomGrammarPointsForPreview(_ items: [GrammarPointModel]) {
        #if DEBUG
            randomGrammarItems = items
        #endif
    }

    func setAlgorithmicGrammarPointsForPreview(_ items: [GrammarPointModel]) {
        #if DEBUG
            algorithmicGrammarItems = items
        #endif
    }
}
