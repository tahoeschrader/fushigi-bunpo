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
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: Error?

    // modelContext: SwiftData database session or “scratchpad”
    // inserts only live in memory until saved
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Public API

    /// Get all grammar points (replaces direct fetchGrammarPoints calls)
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
            print("Failed to fetch remote grammar points:", error)
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
            print("Synced \(remotePoints.count) grammar points")
        } catch {
            print("Failed to save context:", error)
            syncError = error
        }
    }

    /// Manual refresh (pull-to-refresh on scrollable views)
    func refresh() async {
        #if DEBUG
            print("Preview mode: refresh skipped")
        #else
            await syncWithRemote()
        #endif
    }
}
