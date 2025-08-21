//
//  GrammarStore.swift
//  Fushigi
//
//  Created by Tahoe Schrader on 2025/08/14.
//

import Foundation
import SwiftData

// MARK: - Grammar Store

/// Observable store managing grammar points with local SwiftData storage and remote PostgreSQL sync
@MainActor
class GrammarStore: ObservableObject {
    /// In-memory cache of all grammar points for quick UI access
    @Published var grammarItems: [GrammarPointLocal] = []

    /// Daily subset of random grammar points for practice
    @Published private(set) var randomGrammarItems: [GrammarPointLocal] = []

    /// Daily subset of SRS-selected grammar points for practice
    @Published private(set) var algorithmicGrammarItems: [GrammarPointLocal] = []

    /// Sync operation in progress flag
    @Published var isSyncing = false

    /// Last successful sync timestamp
    @Published var lastSyncDate: Date?

    /// Current sync error if any
    @Published var syncError: Error?

    /// Last random subset update date
    private var lastRandomUpdate: Date?

    /// Last algorithmic subset update date
    private var lastAlgorithmicUpdate: Date?

    /// SwiftData database session for local persistence
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - All Grammar

    /// Get all grammar points
    func getAllGrammarPoints() -> [GrammarPointLocal] {
        grammarItems
    }

    /// Get specific grammar point by ID
    func getGrammarPoint(id: UUID?) -> GrammarPointLocal? {
        getAllGrammarPoints().first { $0.id == id }
    }

    /// Filter grammar points by search text across usage, meaning, context, and tags
    func filterGrammarPoints(containing searchText: String? = nil) -> [GrammarPointLocal] {
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
    func getRandomGrammarPoints() -> [GrammarPointLocal] {
        randomGrammarItems
    }

    /// Get specific random grammar point by ID
    func getRandomGrammarPoint(id: UUID?) -> GrammarPointLocal? {
        getRandomGrammarPoints().first { $0.id == id }
    }

    /// Get all SRS grammar points for the day
    func getAlgorithmicGrammarPoints() -> [GrammarPointLocal] {
        algorithmicGrammarItems
    }

    /// Get specific SRS grammar point by ID
    func getAlgorithmicGrammarPoint(id: UUID?) -> GrammarPointLocal? {
        getAlgorithmicGrammarPoints().first { $0.id == id }
    }

    // MARK: - Internal sync logic

    /// Load grammar points from local SwiftData storage
    func loadLocal() async {
        do {
            grammarItems = try modelContext.fetch(FetchDescriptor<GrammarPointLocal>())
            print("Loaded \(grammarItems.count) items from local storage")
        } catch {
            print("Failed to load local grammar points:", error)
        }
    }

    /// Sync grammar points from remote PostgreSQL database
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

    /// Process remote grammar points and update local storage
    private func processRemotePoints(_ remotePoints: [GrammarPointRemote]) async {
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
                let newItem = GrammarPointLocal(
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

    /// Manual refresh for pull-to-refresh functionality
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

    /// Force refresh of daily grammar list based on current mode
    func forceDailyRefresh(currentMode: SourceMode) async {
        switch currentMode {
        case .random:
            updateRandomGrammarPoints(force: true)
        case .srs:
            await updateAlgorithmicGrammarPoints(force: true)
        }
    }

    /// Update random grammar points subset with optional force refresh
    func updateRandomGrammarPoints(force: Bool = false) {
        let today = Calendar.current.startOfDay(for: Date())
        if force || lastRandomUpdate != today || randomGrammarItems.isEmpty {
            randomGrammarItems = Array(grammarItems.shuffled().prefix(5))
            lastRandomUpdate = today
            print("Loaded \(randomGrammarItems.count) new random grammar items from SwiftData.")
        }
    }

    /// Update SRS-based grammar points subset with optional force refresh
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

/// Preview and testing helpers
extension GrammarStore {
    /// Set random grammar points for preview mode only
    func setRandomGrammarPointsForPreview(_ items: [GrammarPointLocal]) {
        #if DEBUG
            randomGrammarItems = items
        #endif
    }

    /// Set algorithmic grammar points for preview mode only
    func setAlgorithmicGrammarPointsForPreview(_ items: [GrammarPointLocal]) {
        #if DEBUG
            algorithmicGrammarItems = items
        #endif
    }
}
