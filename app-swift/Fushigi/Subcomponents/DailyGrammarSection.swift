//
//  DailyGrammarSection.swift
//  Fushigi
//
//  Created by Tahoe Schrader on 2025/08/19.
//

import SwiftUI

/// Daily grammar section displaying curated grammar points for focused practice sessions.
///
/// This view presents a configurable collection of grammar points that users can actively
/// practice with in their journal entries. Each grammar point is displayed with its usage
/// pattern and can be selected for tagging within journal content, creating explicit
/// learning connections between theoretical knowledge and practical application.
///
/// The component supports two sourcing modes: random selection for variety and SRS-based
/// algorithmic selection for spaced repetition learning. Grammar points are displayed
/// with clear visual hierarchy and actionable interfaces for seamless workflow integration.
struct DailyGrammarSection: View {
    /// Centralized grammar data store providing access to filtered and curated grammar points
    @EnvironmentObject var grammarStore: GrammarStore

    /// Currently selected grammar point identifier, coordinated with parent tagging workflow
    @Binding var selectedGrammarID: UUID?

    /// Controls tagging interface visibility, enabling seamless grammar-to-text linking
    @Binding var isShowingTagger: Bool

    /// User-selected grammar sourcing strategy, determining point selection algorithm
    @Binding var selectedSource: SourceMode

    /// Optimal tip placement for current interface layout
    let arrowEdge: Edge = .bottom

    // MARK: - Computed Properties

    /// Dynamically retrieved grammar points based on current sourcing mode and user preferences.
    ///
    /// Returns a curated collection (typically 5 points) selected either randomly for variety
    /// or algorithmically using spaced repetition principles for optimal learning reinforcement.
    private var grammarPoints: [GrammarPointModel] {
        if selectedSource == .random {
            grammarStore.getRandomGrammarPoints()
        } else {
            grammarStore.getAlgorithmicGrammarPoints()
        }
    }

    /// Current error state from grammar store operations, if any.
    ///
    /// Captures synchronization failures, network issues, or data corruption problems
    /// that might prevent proper grammar point display or functionality.
    private var errorMessage: String? {
        grammarStore.syncError?.localizedDescription
    }

    // MARK: - Main View

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.rowSpacing) {
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
                ContentUnavailableView {
                    Label("Grammar Points Unavailable", systemImage: "exclamationmark.triangle")
                } description: {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } actions: {
                    Button("Refresh") {
                        Task {
                            await refreshGrammarPoints()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .frame(minHeight: 120)
            } else if grammarPoints.isEmpty {
                // Empty state with actionable guidance
                ContentUnavailableView {
                    Label("No Grammar Points", systemImage: "book.closed")
                } description: {
                    Text(
                        "No grammar points match your current settings. Try adjusting your filters or refreshing the content.",
                    )
                } actions: {
                    Button("Refresh") {
                        Task {
                            await refreshGrammarPoints()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .frame(minHeight: 120)
            } else {
                // Grammar points display with optimized layout
                LazyVStack(spacing: 8) {
                    ForEach(grammarPoints, id: \.id) { grammarPoint in
                        TaggableGrammarRow(
                            grammarPoint: grammarPoint,
                            onTagSelected: {
                                selectedGrammarID = grammarPoint.id
                                isShowingTagger = true
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

    /// Refreshes grammar points based on current source mode settings.
    ///
    /// Triggers appropriate refresh mechanism (random regeneration or SRS recalculation)
    /// while providing user feedback and handling potential errors gracefully.
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
        DailyGrammarSection(
            selectedGrammarID: .constant(nil),
            isShowingTagger: .constant(false),
            selectedSource: .constant(SourceMode.random),
        )
        .padding()
    }
    .withPreviewGrammarStore(mode: .normal)
}

#Preview("SRS Mode - Normal State") {
    VStack {
        DailyGrammarSection(
            selectedGrammarID: .constant(nil),
            isShowingTagger: .constant(false),
            selectedSource: .constant(SourceMode.srs),
        )
        .padding()
    }
    .withPreviewGrammarStore(mode: .normal)
}

#Preview("Error State") {
    VStack {
        DailyGrammarSection(
            selectedGrammarID: .constant(nil),
            isShowingTagger: .constant(false),
            selectedSource: .constant(SourceMode.random),
        )
        .padding()
    }
    .withPreviewGrammarStore(mode: .syncError)
}

#Preview("Empty State") {
    VStack {
        DailyGrammarSection(
            selectedGrammarID: .constant(nil),
            isShowingTagger: .constant(false),
            selectedSource: .constant(SourceMode.random),
        )
        .padding()
    }
    .withPreviewGrammarStore(mode: .emptyData)
}
