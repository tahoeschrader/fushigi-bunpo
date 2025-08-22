//
//  TaggableGrammarRow.swift
//  Fushigi
//
//  Created by Tahoe Schrader on 2025/08/20.
//

import SwiftUI

// MARK: - Taggable Grammar Row

/// Display row for grammar points with tagging functionality
struct TaggableGrammarRow: View {
    /// Grammar point model containing usage patterns and meanings
    let grammarPoint: GrammarPointLocal

    /// Callback invoked when user selects this grammar point for text tagging
    let onTagSelected: () -> Void

    // MARK: - Main View

    var body: some View {
        HStack(alignment: .center, spacing: UIConstants.Spacing.default) {
            Text(grammarPoint.usage)

            Spacer()

            Button("Add Tag", systemImage: "plus.circle.fill") {
                onTagSelected()
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.plain)
            .foregroundStyle(.mint)
            .help("Link this grammar point to selected text")
        }
    }
}

// MARK: - Previews

#Preview("Grammar Point Row") {
    VStack {
        TaggableGrammarRow(
            grammarPoint: GrammarPointLocal(
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
            grammarPoint: GrammarPointLocal(
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
