//
//  PracticePage.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import SwiftUI

/// A comprehensive view for creating and editing journal entries with targeted grammar point integration.
///
/// This view orchestrates the entire practice workflow, from displaying targeted grammar points
/// to capturing journal entries and managing the tagging relationship between selected text
/// and grammar concepts. It handles both compact (iOS) and regular (iPadOS/macOS) layouts
/// with appropriate presentation methods (sheets vs inspectors).
///
/// The view maintains minimal state, delegating specific concerns to child components while
/// coordinating the overall user experience through bindings and presentation flags.
struct PracticePage: View {
    /// Responsive layout helper for switching between iOS/side-split apps and iPadOS/macOS layouts
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    /// Centralized on-device storage for user's grammar points and application state
    @EnvironmentObject var grammarStore: GrammarStore

    /// Controls the settings sheet that allows users to configure practice content preferences
    @State private var showingSettings = false

    /// Controls the tagging sheet for confirming grammar point and sentence relationships
    @State private var showingTagger = false

    /// Currently selected grammar point identifier for tagging operations
    @State private var selectedGrammarID: UUID?

    /// User preference for politeness level filtering (casual, polite, keigo, sonkeigo, kenjougo)
    @State private var selectedLevel: Level = .all

    /// User preference for usage context filtering (written, spoken, business)
    @State private var selectedContext: Context = .all

    /// User preference for language variants and regional dialects (slang, Kansai)
    @State private var selectedFunMode: FunMode = .none

    /// User preference for grammar sourcing algorithm (random selection vs SRS-based)
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

    private var refreshTip = RefreshTip()

    /// Determines layout strategy based on available horizontal space
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    /// Extracts readable text from TextSelection objects, handling Apple's complex selection API
    ///
    /// TextSelection can represent either simple ranges or complex multi-selections,
    /// this computed property normalizes both cases into a user-readable string.
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
            DailyGrammarSection(
                selectedGrammarID: $selectedGrammarID,
                isShowingTagger: $showingTagger,
                selectedSource: $selectedSource,
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
        .modifier(PresentationModifier(
            isShowingSettings: $showingSettings,
            isShowingTagger: $showingTagger,
            selectedGrammarID: selectedGrammarID,
            selectedText: selectedText,
            isCompact: isCompact,
            selectedLevel: $selectedLevel,
            selectedContext: $selectedContext,
            selectedFunMode: $selectedFunMode,
            selectedSource: $selectedSource,
        ))
        .toolbar {
            Button("Settings", systemImage: "gear") {
                showingSettings.toggle()
            }
            .help("Configure grammar filtering and source preferences")
            Button("Refresh", systemImage: "arrow.clockwise") {
                Task {
                    refreshTip.invalidate(reason: .actionPerformed)
                    await grammarStore.refresh()
                }
            }
            .help("Refresh source of targeted grammar")
            .popoverTip(refreshTip)
        }
    }
}

// MARK: - Presentation Logic

/// Encapsulates sheet and inspector presentation logic to maintain clean separation of concerns.
///
/// This modifier handles the complexity of choosing between sheets (compact layouts) and
/// inspectors (regular layouts) while managing the data flow between the main view and
/// the presented content.
private struct PresentationModifier: ViewModifier {
    @EnvironmentObject var grammarStore: GrammarStore

    @Binding var isShowingSettings: Bool
    @Binding var isShowingTagger: Bool

    let selectedGrammarID: UUID?
    let selectedText: String
    let isCompact: Bool

    @Binding var selectedLevel: Level
    @Binding var selectedContext: Context
    @Binding var selectedFunMode: FunMode
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

    /// Settings configuration view with coordinated state management
    @ViewBuilder
    private var settingsView: some View {
        GrammarSettingsView(
            selectedLevel: $selectedLevel,
            selectedContext: $selectedContext,
            selectedFunMode: $selectedFunMode,
            selectedSource: $selectedSource,
        )
    }

    /// Grammar point tagging interface with proper error handling
    @ViewBuilder
    private var taggerView: some View {
        if let grammarPoint = getGrammarPoint() {
            TaggerView(
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

    /// Retrieves grammar point based on current source mode with proper error handling
    private func getGrammarPoint() -> GrammarPointModel? {
        guard let id = selectedGrammarID else { return nil }

        return selectedSource == .random
            ? grammarStore.getRandomGrammarPoint(id: id)
            : grammarStore.getAlgorithmicGrammarPoint(id: id)
    }
}

// MARK: - Previews

#Preview("Complete Practice View") {
    PracticePage()
        .withPreviewGrammarStore(mode: .normal)
        .withPreviewNavigation()
}

#Preview("Practice View - Error State") {
    PracticePage()
        .withPreviewGrammarStore(mode: .syncError)
        .withPreviewNavigation()
}

#Preview("Practice View - Empty Data") {
    PracticePage()
        .withPreviewGrammarStore(mode: .emptyData)
        .withPreviewNavigation()
}
