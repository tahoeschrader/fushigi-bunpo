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

enum PreviewHelper {
    @MainActor static func withGrammarStore(@ViewBuilder content: @escaping (GrammarStore) -> some View) -> some View {
        do {
            // for previews, we only want the data store to only live in memory while testing
            let container = try ModelContainer(
                for: Schema([GrammarPointModel.self]),
                configurations: [ModelConfiguration(isStoredInMemoryOnly: true)],
            )
            let store = GrammarStore(modelContext: container.mainContext)

            // Populate with fake data
            if store.grammarItems.isEmpty {
                store.grammarItems = [
                    GrammarPointModel(
                        id: UUID(),
                        context: "casual",
                        usage: "Hello",
                        meaning: "こんにちは",
                        tags: ["greeting"],
                    ),
                    GrammarPointModel(
                        id: UUID(),
                        context: "casual",
                        usage: "Goodbye",
                        meaning: "さようなら",
                        tags: ["farewell"],
                    ),
                    GrammarPointModel(id: UUID(), context: "casual", usage: "I", meaning: "私は", tags: ["context"]),
                    GrammarPointModel(
                        id: UUID(),
                        context: "casual",
                        usage: "Cool",
                        meaning: "かっこいい",
                        tags: ["adjective"],
                    ),
                    GrammarPointModel(
                        id: UUID(),
                        context: "casual",
                        usage: "is/am",
                        meaning: "desu",
                        tags: ["sentence-ender"],
                    ),
                ]
            }

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
}

// MARK: - Convenience Extension

extension View {
    func withPreviewGrammarStore() -> some View {
        PreviewHelper.withGrammarStore { _ in
            self
        }
    }
}
