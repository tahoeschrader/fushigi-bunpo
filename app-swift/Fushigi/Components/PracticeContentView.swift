//
//  PracticeContentView.swift
//  Fushigi
//
//  Created by Tahoe Schrader on 2025/08/19.
//

import SwiftUI

/// Main content layout containing grammar section and journal entry form.
///
/// This view defines the overall structure of the practice page, including
/// the daily grammar section, journal entry form, and toolbar.
struct PracticeContentView: View {
    /// On-device storage for user's grammar points
    @EnvironmentObject var grammarStore: GrammarStore

    /// Currently selected grammar point for tagging
    @Binding var selectedGrammarID: UUID?

    /// Controls settings sheet visibility
    @Binding var isShowingSettings: Bool

    /// Controls tagging sheet visibility
    @Binding var isShowingTagger: Bool

    /// Grammar sourcing method setting
    @Binding var selectedSource: SourceMode

    /// Journal entry title
    @Binding var entryTitle: String

    /// Journal entry content
    @Binding var entryContent: String

    /// Text selection from the journal entry
    @Binding var textSelection: TextSelection?

    /// Private entry flag
    @Binding var isPrivateEntry: Bool

    /// Status message for operations
    @Binding var statusMessage: String?

    /// Saving state flag
    @Binding var isSaving: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.defaultSpacing) {
            DailyGrammarSection(
                selectedGrammarID: $selectedGrammarID,
                isShowingTagger: $isShowingTagger,
            )

            JournalEntrySection(
                entryTitle: $entryTitle,
                entryContent: $entryContent,
                textSelection: $textSelection,
                isPrivateEntry: $isPrivateEntry,
                statusMessage: $statusMessage,
                isSaving: $isSaving,
            )
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Settings", systemImage: "gear") {
                    isShowingSettings.toggle()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Refresh") {
                    Task {
                        await refreshGrammarPoints()
                    }
                }
            }
        }
    }

    /// Refreshes grammar points based on current source setting
    private func refreshGrammarPoints() async {
        if selectedSource == .random {
            grammarStore.updateRandomGrammarPoints(force: true)
        } else {
            await grammarStore.updateAlgorithmicGrammarPoints(force: true)
        }
        isShowingSettings = false
    }
}
