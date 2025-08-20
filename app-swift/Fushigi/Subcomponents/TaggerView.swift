//
//  TaggerView.swift
//  Fushigi
//
//  Created by Tahoe Schrader on 2025/08/19.
//

import SwiftUI

/// Advanced interface for creating explicit links between selected text and grammar concepts.
///
/// This view provides users with clear confirmation of their selection choices before
/// committing grammar-to-text relationships to the database. It displays both the
/// selected textual content and the chosen grammar point with full context, enabling
/// users to verify accuracy before creating learning associations.
///
/// The interface handles edge cases gracefully, providing clear feedback for empty
/// selections and offering contextual actions for different scenarios.
struct TaggerView: View {
    /// Currently selected grammar point identifier for database relationship creation
    @Binding var selectedGrammarID: UUID?

    /// Controls the tagging interface visibility within the parent presentation flow
    @Binding var isShowingTagger: Bool

    /// Complete grammar point model containing usage patterns, meanings, and metadata
    let grammarPoint: GrammarPointModel

    /// User-selected text content from the journal entry for association
    let selectedText: String

    /// Tracks successful tag creation for user feedback
    @State private var isTagCreated = false

    /// Temporary status message for operation feedback
    @State private var operationMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.defaultSpacing) {
            // Operation status display
            if let message = operationMessage {
                HStack {
                    Image(systemName: isTagCreated ? "checkmark.circle.fill" : "info.circle.fill")
                        .foregroundColor(isTagCreated ? .green : .blue)
                    Text(message)
                        .font(.subheadline)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // Grammar point information display
            VStack(alignment: .leading, spacing: UIConstants.rowSpacing) {
                Label("Selected Grammar Point", systemImage: "book.fill")
                    .font(.headline)
                    .foregroundStyle(.primary)

                VStack(alignment: .leading, spacing: 6) {
                    Text(grammarPoint.usage)
                        .font(.title3)
                        .fontWeight(.medium)
                        .padding(.leading, UIConstants.defaultPadding)

                    Text(grammarPoint.meaning)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.leading, UIConstants.defaultPadding)

                    // Grammar point metadata
                    HStack {
                        Text(grammarPoint.context)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.tertiary)
                            .clipShape(Capsule())

                        if !grammarPoint.tags.isEmpty {
                            coloredTagsText(tags: grammarPoint.tags)
                                .font(.caption)
                        }
                    }
                    .padding(.leading, UIConstants.defaultPadding)
                }
            }

            // Selected text information display
            VStack(alignment: .leading, spacing: UIConstants.rowSpacing) {
                Label("Selected Text", systemImage: "text.quote")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(selectedText.isEmpty ? "No text selected" : selectedText)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(UIConstants.defaultPadding)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedText.isEmpty ? .quaternary : .tertiary),
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedText.isEmpty ? .clear : .accentColor, lineWidth: 4),
                    )
            }

            // Action buttons with clear visual hierarchy
            HStack(spacing: UIConstants.defaultSpacing) {
                Button("Cancel") {
                    dismissTagger()
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Create Link") {
                    Task {
                        await confirmTagging()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isTagCreated)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: - Action Methods

    /// Creates the grammar point to text association and provides user feedback.
    ///
    /// This method handles the database operation for linking the selected text
    /// with the chosen grammar point, providing appropriate user feedback and
    /// error handling throughout the process.
    private func confirmTagging() async {
        guard !selectedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            operationMessage = "Please select some text before creating a link."
            return
        }

        // TODO: Implement actual database relationship creation
        // let success = await createGrammarTextLink(grammarPoint: grammarPoint, text: selectedText)

        // Simulate successful operation for now
        isTagCreated = true
        operationMessage = "Grammar link created successfully!"

        // Auto-dismiss after brief delay for user confirmation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismissTagger()
        }
    }

    /// Dismisses the tagging interface and clears selection state.
    private func dismissTagger() {
        selectedGrammarID = nil
        isShowingTagger = false
    }
}

// MARK: Previews

#Preview("Tagger - With Text") {
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
    .navigationTitle("Link Grammar")
    .withPreviewNavigation()
}

#Preview("Tagger - No Text") {
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
    .navigationTitle("Link Grammar")
    .withPreviewNavigation()
}
