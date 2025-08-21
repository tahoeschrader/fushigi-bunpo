//
//  PracticePage.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import SwiftUI

// MARK: - Practice Page

/// View for creating journal entries with targeted grammar point integration
struct PracticePage: View {
    /// Responsive layout helper for switching between iOS/side-split apps and iPadOS/macOS layouts
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    /// Centralized on-device storage for user's grammar points and application state
    @EnvironmentObject var grammarStore: GrammarStore

    /// Controls the settings sheet for practice content preferences
    @State private var showingSettings = false

    /// Controls the tagging sheet for grammar point and sentence relationships
    @State private var showingTagger = false

    /// Currently selected grammar point identifier for tagging operations
    @State private var selectedGrammarID: UUID?

    /// User preference for politeness level filtering
    @State private var selectedLevel: Level = .all

    /// User preference for usage context filtering
    @State private var selectedContext: Context = .all

    /// User preference for language variants and regional dialects
    @State private var selectedFunMode: FunMode = .none

    /// User preference for grammar sourcing algorithm
    @State private var selectedSource: SourceMode = .random

    /// User-entered title for the current journal entry
    @State private var entryTitle = ""

    /// Main content of the journal entry where users practice grammar usage
    @State private var entryContent = ""

    /// Text selection capture from journal content for grammar point association
    @State private var textSelection: TextSelection?

    /// Privacy flag for future social features and content sharing
    @State private var isPrivateEntry = false

    /// User-visible message for displaying operation results and feedback
    @State private var statusMessage: String?

    /// Loading state flag to disable UI elements during async operations
    @State private var isSaving = false

    let refreshTip = RefreshTip()

    /// Determines layout strategy based on available horizontal space
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    /// Extracts readable text from TextSelection objects for tagging
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
        VStack(alignment: .leading, spacing: UIConstants.defaultSpacing) {
            DailyGrammar(
                selectedGrammarID: $selectedGrammarID,
                isShowingTagger: $showingTagger,
                selectedSource: $selectedSource,
            )

            JournalEntryForm(
                entryTitle: $entryTitle,
                entryContent: $entryContent,
                textSelection: $textSelection,
                isPrivateEntry: $isPrivateEntry,
                statusMessage: $statusMessage,
                isSaving: $isSaving,
            )
        }
        .padding()
        .modifier(
            PresentationModifier(
                isShowingSettings: $showingSettings,
                isShowingTagger: $showingTagger,
                selectedGrammarID: selectedGrammarID,
                selectedText: selectedText,
                isCompact: isCompact,
                selectedLevel: $selectedLevel,
                selectedContext: $selectedContext,
                selectedFunMode: $selectedFunMode,
                selectedSource: $selectedSource,
            ),
        )
        .toolbar {
            Button("Settings", systemImage: "gear") {
                showingSettings.toggle()
            }
            .help("Configure grammar filtering and source preferences")
            Button("Refresh", systemImage: "arrow.clockwise") {
                refreshTip.invalidate(reason: .actionPerformed)
                Task {
                    await refreshGrammarPoints()
                }
            }
            .help("Refresh source of targeted grammar")
            .buttonStyle(.plain)
            .popoverTip(refreshTip)
        }
    }

    // MARK: - Helper Methods

    /// Refreshes grammar points based on current source setting
    private func refreshGrammarPoints() async {
        await grammarStore.forceDailyRefresh(currentMode: selectedSource)
        showingSettings = false
    }
}

// MARK: - Presentation Logic

/// Handles sheet and inspector presentation for compact vs regular layouts
private struct PresentationModifier: ViewModifier {
    /// Grammar store for retrieving grammar point data
    @EnvironmentObject var grammarStore: GrammarStore

    /// Controls settings sheet visibility
    @Binding var isShowingSettings: Bool

    /// Controls tagger sheet visibility
    @Binding var isShowingTagger: Bool

    /// Currently selected grammar point ID
    let selectedGrammarID: UUID?

    /// Selected text from journal content
    let selectedText: String

    /// Layout mode indicator
    let isCompact: Bool

    /// User preference for politeness level filtering
    @Binding var selectedLevel: Level

    /// User preference for usage context filtering
    @Binding var selectedContext: Context

    /// User preference for language variants
    @Binding var selectedFunMode: FunMode

    /// User preference for grammar sourcing algorithm
    @Binding var selectedSource: SourceMode

    func body(content: Content) -> some View {
        if isCompact {
            content
                .sheet(isPresented: $isShowingSettings) {
                    settingsView.presentationDetents([.medium])
                }
                .sheet(isPresented: $isShowingTagger) {
                    taggerView.presentationDetents([.fraction(0.25), .medium])
                }

        } else {
            content
                .inspector(isPresented: $isShowingSettings) { settingsView }
                .inspector(isPresented: $isShowingTagger) { taggerView }
        }
    }

    /// Settings configuration view with state management
    @ViewBuilder
    private var settingsView: some View {
        GrammarSettings(
            selectedLevel: $selectedLevel,
            selectedContext: $selectedContext,
            selectedFunMode: $selectedFunMode,
            selectedSource: $selectedSource,
        )
    }

    /// Grammar point tagging interface with error handling
    @ViewBuilder
    private var taggerView: some View {
        if let grammarPoint = getGrammarPoint() {
            Tagger(
                selectedGrammarID: .constant(selectedGrammarID),
                isShowingTagger: $isShowingTagger,
                grammarPoint: grammarPoint,
                selectedText: selectedText,
            )
        } else {
            ContentUnavailableView {
                Label("Grammar Point Unavailable", systemImage: "exclamationmark.triangle")
            } description: {
                Text("The selected grammar point could not be loaded. Please try selecting another point.")
            } actions: {
                Button("Dismiss") {
                    isShowingTagger = false
                }
            }
        }
    }

    /// Retrieves grammar point based on current source mode
    private func getGrammarPoint() -> GrammarPointLocal? {
        guard let id = selectedGrammarID else { return nil }

        return selectedSource == .random
            ? grammarStore.getRandomGrammarPoint(id: id)
            : grammarStore.getAlgorithmicGrammarPoint(id: id)
    }
}

// MARK: - Previews

#Preview("Normal State") {
    PracticePage()
        .withPreviewGrammarStore(mode: .normal)
        .withPreviewNavigation()
}

#Preview("Error State") {
    PracticePage()
        .withPreviewGrammarStore(mode: .syncError)
        .withPreviewNavigation()
}

#Preview("Empty Data") {
    PracticePage()
        .withPreviewGrammarStore(mode: .emptyData)
        .withPreviewNavigation()
}
