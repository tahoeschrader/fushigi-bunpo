//
//  GrammarPointRow.swift
//  Fushigi
//
//  Created by Tahoe Schrader on 2025/08/19.
//

import SwiftUI

/// Individual row in the daily grammar section.
///
/// Each row displays a grammar point's usage with a button to select it for tagging.
/// The design is intentionally simple to keep focus on the grammar content.
struct GrammarPointRow: View {
    /// The grammar point to display
    let grammarPoint: GrammarPointModel

    /// Callback when the grammar point is selected for tagging
    let onTagSelected: () -> Void

    var body: some View {
        HStack {
            Text(grammarPoint.usage)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.primary)
                .padding(.leading, UIConstants.defaultPadding)

            Spacer()

            Button("Add Tag", systemImage: "plus") {
                onTagSelected()
            }
            .bold()
            .labelStyle(.iconOnly)
        }
    }
}

// MARK: Previews

#Preview("Grammar Point Row") {
    VStack {
        GrammarPointRow(
            grammarPoint: GrammarPointModel(
                id: UUID(),
                context: "N3",
                usage: "〜ながら",
                meaning: "while doing",
                tags: ["simultaneous", "action"],
            ),
            onTagSelected: { print("Tag selected for preview") },
        )
        Divider()
        GrammarPointRow(
            grammarPoint: GrammarPointModel(
                id: UUID(),
                context: "N2",
                usage: "〜たとえ...ても",
                meaning: "even if",
                tags: ["conditional", "emphasis"],
            ),
            onTagSelected: { print("Tag selected for preview") },
        )
    }
    .padding()
}
