//
//  TaggerView.swift
//  Fushigi
//
//  Created by Tahoe Schrader on 2025/08/19.
//

import SwiftUI

/// A view for linking sentences with grammar points.
///
/// This view provides confirmation of selected sentences and grammar points,
/// showing usage hints and providing buttons to save the relationship to the database.
struct TaggerView: View {
    /// Currently selected grammar point ID, shared from PracticeView
    @Binding var selectedGrammarID: UUID?

    /// Controls the tagging sheet visibility, shared from PracticeView
    @Binding var isShowingTagger: Bool

    /// The full grammar point model for displaying usage, level, and context
    let grammarPoint: GrammarPointModel

    /// The selected text content for tagging
    let selectedText: String

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.defaultSpacing) {
            // Action buttons
            HStack {
                Button("Cancel") {
                    dismissTagger()
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Confirm") {
                    // TODO: Create a route to log this relationship
                    dismissTagger()
                }
                .buttonStyle(.bordered)
            }

            // Grammar point display
            VStack(alignment: .leading, spacing: UIConstants.rowSpacing) {
                Text("Selected Grammar Point:").bold()
                Text(grammarPoint.usage)
                    .italic()
                    .padding(.leading, UIConstants.defaultPadding)
                Text(grammarPoint.meaning)
                    .italic()
                    .foregroundColor(.secondary)
                    .padding(.leading, UIConstants.defaultPadding)
            }

            // Selected text display
            VStack(alignment: .leading, spacing: UIConstants.rowSpacing) {
                Text("Selected Sentence(s):").bold()
                Text(selectedText.isEmpty ? "No text selected" : selectedText)
                    .italic()
                    .padding(.leading, UIConstants.defaultPadding)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    /// Helper to dismiss the tagger and clear selection
    private func dismissTagger() {
        selectedGrammarID = nil
        isShowingTagger = false
    }
}

// MARK: Previews

#Preview("With Selection") {
    TaggerView(
        selectedGrammarID: .constant(UUID()),
        isShowingTagger: .constant(true),
        grammarPoint: GrammarPointModel(
            id: UUID(),
            context: "N3",
            usage: "〜ながら",
            meaning: "while doing",
            tags: ["simultaneous", "action"],
        ),
        selectedText: "私は音楽を聞きながら勉強しています。",
    )
}

#Preview("No Selection") {
    TaggerView(
        selectedGrammarID: .constant(UUID()),
        isShowingTagger: .constant(true),
        grammarPoint: GrammarPointModel(
            id: UUID(),
            context: "N2",
            usage: "〜というのは",
            meaning: "the reason is that",
            tags: ["explanation", "formal"],
        ),
        selectedText: "",
    )
}
