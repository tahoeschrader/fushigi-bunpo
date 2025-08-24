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

    /// Current database state from data synchronization operations
    private var dataState: DataState {
        grammarStore.dataState
    }

    // MARK: - Main View

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.Spacing.row) {
            HStack {
                Text("Targeted Grammar")
                    .font(.headline)

                Spacer()

                Text(selectedSource.id)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, UIConstants.Padding.capsuleWidth)
                    .padding(.vertical, UIConstants.Padding.capsuleHeight)
                    .background(.quaternary)
                    .clipShape(.capsule)
            }

            Divider()

            switch dataState {
            case .syncError, .postgresConnectionError, .emptyData:
                dataState.contentUnavailableView { await grammarStore.refresh() }
            case .networkLoading:
                dataState.contentUnavailableView {}
            case .normal:
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
    .withPreviewStores(mode: .normal)
}

#Preview("SRS Mode - Normal State") {
    VStack {
        DailyGrammar(
            showTagger: .constant(false),
            selectedSource: .constant(SourceMode.srs),
        )
        .padding()
    }
    .withPreviewStores(mode: .normal)
}

#Preview("Error State") {
    VStack {
        DailyGrammar(
            showTagger: .constant(false),
            selectedSource: .constant(SourceMode.random),
        )
        .padding()
    }
    .withPreviewStores(mode: .syncError)
}

#Preview("Empty State") {
    VStack {
        DailyGrammar(
            showTagger: .constant(false),
            selectedSource: .constant(SourceMode.random),
        )
        .padding()
    }
    .withPreviewStores(mode: .emptyData)
}
