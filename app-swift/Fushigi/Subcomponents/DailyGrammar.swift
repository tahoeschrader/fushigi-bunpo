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

    /// Controls tagging interface visibility
    @Binding var showTagger: Bool

    /// User-selected grammar sourcing strategy
    @Binding var selectedSource: SourceMode

    /// Grammar points based on current sourcing mode
    private var grammarPoints: [GrammarPointLocal] {
        grammarStore.getGrammarPoints(for: selectedSource)
    }

    /// Current error state from grammar store operations
    private var errorMessage: String? {
        grammarStore.syncError?.localizedDescription
    }

    // TODO: FIgure this out
    private var isSyncing: Bool {
        grammarStore.isSyncing
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
                    .padding(.horizontal, UIConstants.Padding.capsuleWidth)
                    .padding(.vertical, UIConstants.Padding.capsuleHeight)
                    .background(.quaternary)
                    .clipShape(.capsule)
            }

            Divider()

            // Error state handling with clear user guidance
            if isSyncing {
                ContentUnavailableView {
                    VStack(spacing: UIConstants.Spacing.section) {
                        ProgressView()
                            .scaleEffect(2.5)
                            .frame(height: UIConstants.Sizing.icons)
                        Text("Loading")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                } description: {
                    Text("Fetching your grammar points...")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage {
                errorStateView(message: "Error: \(errorMessage)")
            } else {
                // Grammar points display with optimized layout
                VStack {
                    ForEach(grammarPoints, id: \.id) { grammarPoint in
                        TaggableGrammarRow(
                            grammarPoint: grammarPoint,
                            onTagSelected: {
                                grammarStore.selectedGrammarPoint = grammarPoint
                                showTagger = true
                            },
                        )
                        Divider()
                    }
                }
            }
        }
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Previews

#Preview("Random Mode - Normal State") {
    VStack {
        DailyGrammar(
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
            showTagger: .constant(false),
            selectedSource: .constant(SourceMode.random),
        )
        .padding()
    }
    .withPreviewGrammarStore(mode: .emptyData)
}
