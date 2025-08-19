//
//  PracticeView.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import SwiftUI

/// A main view for creating and editing journal entries with targeted grammar point integration.
///
/// This view provides a form for users to write journal entries while displaying
/// targeted grammar points that can be tagged within the content. A settings menu
/// allows users to configure what type of content they want to practice.
struct PracticeView: View {
    /// Helper for switching between iOS/side-split apps and iPadOS/MacOS layouts
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    /// On-device storage for user's grammar points
    @EnvironmentObject var grammarStore: GrammarStore

    /// Shows the settings sheet that lets users configure practice content
    @State private var isShowingSettings = false

    /// Shows the tagging sheet to confirm grammar and sentence linking
    @State private var isShowingTagger = false

    /// Setting for politeness level (casual, polite, keigo, sonkeigo, kenjougo)
    @State private var selectedLevel: Level = .all

    /// Setting for usage context (written, spoken, business)
    @State private var selectedContext: Context = .all

    /// Setting for language variants (slang, Kansai dialect)
    @State private var selectedFunMode: FunMode = .none

    /// Setting for grammar sourcing method (random or SRS algorithm)
    @State private var selectedSource: SourceMode = .random

    /// Currently selected grammar point for tagging
    @State private var selectedGrammarID: UUID?

    /// Title of the journal entry
    @State private var entryTitle = ""

    /// Content of the journal entry
    @State private var entryContent = ""

    /// Text selection from the journal entry via drag gestures
    @State private var textSelection: TextSelection?

    /// Whether to mark journal entry as private for future social features
    @State private var isPrivateEntry = false

    /// Global message holder for displaying operation results
    @State private var statusMessage: String?

    /// Disables UI while async operations are running
    @State private var isSaving = false

    /// Helper for switching between compact and regular layouts
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    /// Converts TextSelection objects into strings due to Apple API complexity
    private var selectedText: String {
        guard let selection = textSelection, !selection.isInsertion else { return "" }

        switch selection.indices {
        case let .selection(range):
            return String(entryContent[range])
        case let .multiSelection(ranges):
            return ranges.ranges.map { String(entryContent[$0]) }.joined(separator: "\n")
        @unknown default:
            print("Debug PracticeView: TextSelection: unknown case: \(selection.indices)")
            return ""
        }
    }

    // MARK: - Main View

    var body: some View {
        if isCompact {
            NavigationStack { practiceContentView }
                .sheet(isPresented: $isShowingSettings) { settingsView }
                .sheet(isPresented: $isShowingTagger) { taggerView }
        } else {
            practiceContentView
                .inspector(isPresented: $isShowingSettings) { settingsView }
                .inspector(isPresented: $isShowingTagger) { taggerView }
        }
    }

    // MARK: - View Builders

    /// Main content view containing grammar section and entry form
    @ViewBuilder
    private var practiceContentView: some View {
        PracticeContentView(
            selectedGrammarID: $selectedGrammarID,
            isShowingSettings: $isShowingSettings,
            isShowingTagger: $isShowingTagger,
            selectedSource: $selectedSource,
            entryTitle: $entryTitle,
            entryContent: $entryContent,
            textSelection: $textSelection,
            isPrivateEntry: $isPrivateEntry,
            statusMessage: $statusMessage,
            isSaving: $isSaving,
        )
    }

    /// Settings view for configuring grammar targeting preferences
    @ViewBuilder
    private var settingsView: some View {
        GrammarSettingsView(
            selectedLevel: $selectedLevel,
            selectedContext: $selectedContext,
            selectedFunMode: $selectedFunMode,
            selectedSource: $selectedSource,
        )
    }

    /// Tagging view for confirming sentence and grammar point links
    @ViewBuilder
    private var taggerView: some View {
        if let grammarPoint = grammarStore.getRandomGrammarPoint(id: selectedGrammarID) {
            TaggerView(
                selectedGrammarID: $selectedGrammarID,
                isShowingTagger: $isShowingTagger,
                grammarPoint: grammarPoint,
                selectedText: selectedText,
            )
        }
    }
}

// MARK: - Previews

#Preview("Complete Practice View") {
    PracticeView()
        .withPreviewGrammarStore()
}
