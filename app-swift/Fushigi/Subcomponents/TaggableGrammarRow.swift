//
//  TaggableGrammarRow.swift
//  Fushigi
//
//  Created by Tahoe Schrader on 2025/08/20.
//

import SwiftUI

/// Individual display row for grammar points within the daily practice section.
///
/// Each row presents a grammar point's essential information in a scannable format,
/// with clear visual hierarchy prioritizing the usage pattern and meaning. The
/// interactive "Add Tag" button enables users to create explicit connections between
/// theoretical grammar concepts and their practical application in journal entries.
///
/// The design intentionally maintains visual simplicity to keep cognitive focus on
/// the grammar content rather than interface complexity, supporting effective learning.
struct TaggableGrammarRow: View {
    /// The grammar point model containing usage patterns, meanings, and metadata
    let grammarPoint: GrammarPointModel

    /// Callback invoked when user selects this grammar point for text tagging
    let onTagSelected: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: UIConstants.defaultSpacing) {
            Text(grammarPoint.usage)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Spacer()

            Button("Add Tag", systemImage: "plus.circle.fill") {
                onTagSelected()
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
            .help("Link this grammar point to selected text")
        }
    }
}

#Preview("Grammar Point Row") {
    VStack {
        TaggableGrammarRow(
            grammarPoint: GrammarPointModel(
                id: UUID(),
                context: "Written",
                usage: "〜ながら",
                meaning: "while doing",
                tags: ["simultaneous", "action"],
            ),
            onTagSelected: { print("Tag selected for preview") },
        )

        Divider()

        TaggableGrammarRow(
            grammarPoint: GrammarPointModel(
                id: UUID(),
                context: "Spoken",
                usage: "〜たとえ...ても",
                meaning: "even if",
                tags: ["conditional", "emphasis"],
            ),
            onTagSelected: { print("Tag selected for preview") },
        )
    }
    .padding()
}
