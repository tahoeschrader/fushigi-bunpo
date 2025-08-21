//
//  DailyGrammar.swift
//  Fushigi
//
//  Created by Tahoe Schrader on 2025/08/19.
//

import SwiftUI

// MARK: - Daily Grammar

/// Daily grammar section displaying curated grammar points for practice sessions
struct DailyGrammar: View {
    /// Centralized grammar data store
    @EnvironmentObject var grammarStore: GrammarStore

    /// Currently selected grammar point identifier for tagging workflow
    @Binding var selectedGrammarID: UUID?

    /// Controls tagging interface visibility
    @Binding var showTagger: Bool

    /// User-selected grammar sourcing strategy
    @Binding var selectedSource: SourceMode

    /// Tip placement edge for current interface layout
    let arrowEdge: Edge = .bottom

    /// Grammar points based on current sourcing mode
    private var grammarPoints: [GrammarPointLocal] {
        grammarStore.getGrammarPoints(for: selectedSource)
    }

    /// Current error state from grammar store operations
    private var errorMessage: String? {
        grammarStore.syncError?.localizedDescription
    }

    // MARK: - Main View

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.Spacing.row) {
            // Section header with dynamic sourcing mode indicator
            HStack {
                Text("Targeted Grammar")
                    .font(.headline)

                Spacer()

                // Source mode indicator with subtle styling
                Text(selectedSource.id)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.quaternary)
                    .clipShape(Capsule())
            }

            Divider()

            // Error state handling with clear user guidance
            if let errorMessage {
                errorStateView(message: "Error: \(errorMessage)")
            } else if grammarPoints.isEmpty {
                errorStateView(message:
                    "No grammar points match your current settings." +
                        "Try adjusting your filters or refreshing the content.")
            } else {
                // Grammar points display with optimized layout
                LazyVStack(spacing: 8) {
                    ForEach(grammarPoints, id: \.id) { grammarPoint in
                        TaggableGrammarRow(
                            grammarPoint: grammarPoint,
                            onTagSelected: {
                                selectedGrammarID = grammarPoint.id
                                showTagger = true
                            },
                        )

                        // Subtle visual separation between points
                        if grammarPoint.id != grammarPoints.last?.id {
                            Divider()
                                .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: grammarPoints.count)
        .animation(.easeInOut(duration: 0.3), value: errorMessage)
    }

    // MARK: - Helper Methods

    /// Refresh grammar points based on current source mode
    private func refreshGrammarPoints() async {
        if selectedSource == .random {
            grammarStore.updateRandomGrammarPoints(force: true)
        } else {
            await grammarStore.updateAlgorithmicGrammarPoints(force: true)
        }
    }

    @ViewBuilder
    private func errorStateView(message: String) -> some View {
        ContentUnavailableView {
            Label("Grammar Points Unavailable", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message).foregroundColor(.red)
        } actions: {
            Button("Refresh") { Task { await refreshGrammarPoints() } }
                .buttonStyle(.bordered)
        }
        .frame(minHeight: 120)
    }
}

// MARK: - Previews

#Preview("Random Mode - Normal State") {
    VStack {
        DailyGrammar(
            selectedGrammarID: .constant(nil),
            showTagger: .constant(false),
            selectedSource: .constant(SourceMode.random),
        )
        .padding()
    }
    .withPreviewGrammarStore(mode: .normal)
}

#Preview("SRS Mode - Normal State") {
    VStack {
        DailyGrammar(
            selectedGrammarID: .constant(nil),
            showTagger: .constant(false),
            selectedSource: .constant(SourceMode.srs),
        )
        .padding()
    }
    .withPreviewGrammarStore(mode: .normal)
}

#Preview("Error State") {
    VStack {
        DailyGrammar(
            selectedGrammarID: .constant(nil),
            showTagger: .constant(false),
            selectedSource: .constant(SourceMode.random),
        )
        .padding()
    }
    .withPreviewGrammarStore(mode: .syncError)
}

#Preview("Empty State") {
    VStack {
        DailyGrammar(
            selectedGrammarID: .constant(nil),
            showTagger: .constant(false),
            selectedSource: .constant(SourceMode.random),
        )
        .padding()
    }
    .withPreviewGrammarStore(mode: .emptyData)
}
