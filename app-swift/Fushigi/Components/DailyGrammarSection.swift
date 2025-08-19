//
//  DailyGrammarSection.swift
//  Fushigi
//
//  Created by Tahoe Schrader on 2025/08/19.
//

import SwiftUI

/// Daily grammar section displaying targeted grammar points.
///
/// This view shows a configurable list of grammar points that users can
/// practice with. Each grammar point can be selected for tagging within journal entries.
struct DailyGrammarSection: View {
    /// On-device storage for user's grammar points
    @EnvironmentObject var grammarStore: GrammarStore

    /// Currently selected grammar point for tagging
    @Binding var selectedGrammarID: UUID?

    /// Controls tagging sheet visibility
    @Binding var isShowingTagger: Bool

    /// Grammar points retrieved from store (5 random points by default)
    private var grammarPoints: [GrammarPointModel] {
        grammarStore.getRandomGrammarPoints()
    }

    /// Error message from grammar store operations
    private var errorMessage: String? {
        grammarStore.syncError?.localizedDescription
    }

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.rowSpacing) {
            Text("Today's Target").font(.headline)
            Divider()

            if let errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .font(.caption)
            } else {
                LazyVStack(spacing: 5) {
                    ForEach(grammarPoints, id: \.id) { grammarPoint in
                        GrammarPointRow(
                            grammarPoint: grammarPoint,
                            onTagSelected: {
                                selectedGrammarID = grammarPoint.id
                                isShowingTagger = true
                            },
                        )
                        Divider()
                    }
                }
            }
        }
    }
}

// MARK: Previews

#Preview("Full View") {
    NavigationStack {
        DailyGrammarSection(
            selectedGrammarID: .constant(nil),
            isShowingTagger: .constant(false),
        )
        .padding()
    }
    .withPreviewGrammarStore()
}
