//
//  PracticeView.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import SwiftUI

/// A Main View for creating and editing journal entries with targeted grammar point integration.
///
/// This view provides a form for users to write journal entries while displaying
/// targeted grammar points that can be tagged within the content. A settings menu
/// is provided that let's the user dial in what type of content they wan't to practice.
struct PracticeView: View {
    /// A helper class to aid in easily switching between iOS/side-split apps and iPadOS/MacOS
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    /// On device storage a user's grammar points
    @EnvironmentObject var grammarStore: GrammarStore

    /// A flag to open the settings sheet that lets users dial in what type of content they want to practice
    @State private var showingSettingsSheet = false

    /// A flag to open the tagging sheet to confirm the grammar and sentence a user wants to link
    @State private var showingTaggingSheet = false

    /// A setting corresponding to tags such as casual, polite, keigo, sonkeigo, and kenjougo
    @State private var selectedLevel: Level = .all

    /// A setting corresponding to tags such as written, spoken, and business
    @State private var selectedContext: Context = .all

    /// A setting corresponding to tags such as slang or Kansai dialect
    @State private var selectedFunMode: FunMode = .none

    /// A setting corresponding whether to source grammar at random or via SRS
    @State private var selectedSource: SourceMode = .random

    /// The currently selected grammar point for tagging
    @State private var selectedGrammarID: UUID?

    /// The title of the journal entry
    @State private var title = ""

    /// The content of the journal entry
    @State private var content = ""

    /// A substring from the journal entry that the user has purposefully selected via drag gestures
    @State private var selection: TextSelection?

    /// A flag whether to set a journal entry as private for future social mechanics (TODO: implement social mechanics)
    @State private var isPrivate = false

    /// A global error message holder for writing errors to the screen (TODO: make notification popup)
    @State private var resultMessage: String?

    /// A flag to turn off interactable user infaces while async functions are running
    @State private var isSaving = false

    /// A helper variable  to aid in easily switching between iOS/side-split apps and iPadOS/MacOS
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    /// A helper variable to convert TextSelection objects into an actual string due to weird Apple API
    private var selectedText: String {
        // Skip if the selection is an insertion (cursor)
        guard let sel = selection, !sel.isInsertion else { return "" }

        switch sel.indices {
        case let .selection(range):
            return String(content[range])
        case let .multiSelection(ranges):
            return ranges.ranges.map { String(content[$0]) }.joined(separator: "\n")
        @unknown default:
            print("Debug JournalEntryView: TextSelection: unknown case: \(sel.indices)")
            return ""
        }
    }

    // MARK: - Practice Wrapper

    /// User interface for the PracticeView page
    var body: some View {
        if isCompact {
            // Need the navigation stack for compact since it's instantiated with TabView
            NavigationStack { practiceContentView }
                .sheet(isPresented: $showingSettingsSheet) { settingsView }
                .sheet(isPresented: $showingTaggingSheet) { taggerView }
        } else {
            practiceContentView
                .inspector(isPresented: $showingSettingsSheet) { settingsView }
                .inspector(isPresented: $showingTaggingSheet) { taggerView }
        }
    }

    // MARK: - Helper Builders

    /// Helper View to simplify code: consists of DailyGrammarSection + JournalEntrySection
    @ViewBuilder
    private var practiceContentView: some View {
        PracticeContentView(
            selectedGrammarID: $selectedGrammarID,
            showingSettingsSheet: $showingSettingsSheet,
            showingTaggingSheet: $showingTaggingSheet,
            selectedSource: $selectedSource,
            title: $title,
            content: $content,
            selection: $selection,
            isPrivate: $isPrivate,
            resultMessage: $resultMessage,
            isSaving: $isSaving,
            selectedText: selectedText,
        )
    }

    /// Helper View to simplify code: consists of the settings page for users to edit what grammar is targeted
    @ViewBuilder
    private var settingsView: some View {
        GrammarSettingsView(
            selectedLevel: $selectedLevel,
            selectedContext: $selectedContext,
            selectedFunMode: $selectedFunMode,
            selectedSource: $selectedSource,
        )
    }

    /// Helper View to simplify code: consists of the tagger page for users to confirm sentence and grammar links
    @ViewBuilder
    private var taggerView: some View {
        // TODO: must get this to work with either Random or SRS
        if let selectedGrammarPoint = grammarStore.getRandomGrammarPoint(id: selectedGrammarID) {
            TaggerView(
                selectedGrammarID: $selectedGrammarID,
                showingTaggingSheet: $showingTaggingSheet,
                selectedGrammarPoint: selectedGrammarPoint,
                selectedText: selectedText,
            )
        }
    }
}

// MARK: - Tagger

/// A Helper View for linking sentences with grammar points.
///
/// This view provides a simple confirmation of what sentence has been selected
/// and which grammar point was clicked. Some extra information is shown such as
/// hints on how to use the grammar point as well as buttons to add this information
/// to the internal database.
struct TaggerView: View {
    /// The currently selected grammar point for tagging: shared from PracticeView
    @Binding var selectedGrammarID: UUID?

    /// A flag to open the tagging sheet to confirm the grammar and sentence a user wants to link: shared from
    /// PracticeView
    @Binding var showingTaggingSheet: Bool

    /// The currently selected grammar point as a full model for showing usage, level, nuance, etc.
    var selectedGrammarPoint: GrammarPointModel?

    /// The actual selected text content as a string for tagging to a grammar point
    var selectedText: String

    /// User interface for the TaggerView page
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Button("Cancel") {
                    selectedGrammarID = nil
                    showingTaggingSheet = false
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Confirm") {
                    // TODO: Create a route to log this
                    selectedGrammarID = nil
                    showingTaggingSheet = false
                }
                .buttonStyle(.bordered)
            }
            Text("Selected grammar point:").bold()
            Text(selectedGrammarPoint?.usage ?? "No grammar point selected").italic().padding(.leading, 10)
            Text("Selected sentence(s):").bold()
            Text(selectedText != "" ? selectedText : "No grammar point selected").italic().padding(.leading, 10)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// MARK: - Practice Content

/// A Helper View for defining all the sub-components making up the PracticeView.
///
/// This view mostly just defines the SwiftUI makeup of the PracticeView page, including the
/// DailyGrammarSection, JournalEntrySection, and toolbars.
struct PracticeContentView: View {
    /// On device storage a user's grammar points
    @EnvironmentObject var grammarStore: GrammarStore

    /// The currently selected grammar point for tagging
    @Binding var selectedGrammarID: UUID?

    /// A flag to open the tagging sheet to confirm the grammar and sentence a user wants to link
    @Binding var showingSettingsSheet: Bool

    /// A flag to open the tagging sheet to confirm the grammar and sentence a user wants to link
    @Binding var showingTaggingSheet: Bool

    /// A setting corresponding whether to source grammar at random or via SRS
    @Binding var selectedSource: SourceMode

    /// The title of the journal entry
    @Binding var title: String

    /// The content of the journal entry
    @Binding var content: String

    /// A substring from the journal entry that the user has purposefully selected via drag gestures
    @Binding var selection: TextSelection?

    /// A flag whether to set a journal entry as private for future social mechanics (TODO: implement social mechanics)
    @Binding var isPrivate: Bool

    /// A global error message holder for writing errors to the screen (TODO: make notification popup)
    @Binding var resultMessage: String?

    /// A flag to turn off interactable user infaces while async functions are running
    @Binding var isSaving: Bool

    /// The actual selected text content as a string for tagging to a grammar point
    var selectedText: String

    /// User interface for the PracticeContent page
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            DailyGrammarSection(
                selectedGrammarID: $selectedGrammarID,
                showingSettingsSheet: $showingSettingsSheet,
                showingTaggingSheet: $showingTaggingSheet,
            )

            JournalEntrySection(
                title: $title,
                content: $content,
                selection: $selection,
                isPrivate: $isPrivate,
                resultMessage: $resultMessage,
                isSaving: $isSaving,
                selectedText: selectedText,
            )
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    showingSettingsSheet.toggle()
                } label: {
                    Label("More Info", systemImage: "gear")
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Refresh") {
                    Task {
                        if selectedSource == .random {
                            grammarStore.updateRandomGrammarPoints(force: true)
                        } else {
                            await grammarStore.updateAlgorithmicGrammarPoints(force: true)
                        }
                    }
                    showingSettingsSheet = false
                }
            }
        }
    }
}

// MARK: - Daily Grammar Section

/// A Helper View for the Daily Grammar Section where users are shown 5 grammar to focus on.
///
/// This view is a simple list with a button that brings up extra information as well as a tagger. The 5 specific
/// grammar points that show up can be configurable in the settings menu.
struct DailyGrammarSection: View {
    /// On device storage a user's grammar points
    @EnvironmentObject var grammarStore: GrammarStore

    /// The currently selected grammar point for tagging
    @Binding var selectedGrammarID: UUID?

    /// A flag to open the tagging sheet to confirm the grammar and sentence a user wants to link
    @Binding var showingSettingsSheet: Bool

    /// A flag to open the tagging sheet to confirm the grammar and sentence a user wants to link
    @Binding var showingTaggingSheet: Bool

    /// Grammar points pulled from the store corresponding to five at random by default
    private var grammarPoints: [GrammarPointModel] {
        grammarStore.getRandomGrammarPoints()
    }

    /// An error message holder for writing errors to the screen (TODO: make notification popup)
    private var errorMessage: String? {
        grammarStore.syncError?.localizedDescription
    }

    /// User interface for the DailyGrammarSection page
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Today's Target").font(.headline)
                Spacer()
            }

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
                                showingTaggingSheet = true
                            },
                        )
                        Divider()
                    }
                }
            }
        }
    }
}

// MARK: - Individual Grammar Point Row

/// A Helper View for expressing exactly what each row of the Daily Grammar Section list looks like.
///
/// This view is as simple as can be for now with just the text and a  + button separated by a spacer.
/// I am currently not sure how this can be improved.
struct GrammarPointRow: View {
    /// The current grammar point as a full model for showing usage, level, nuance, etc
    let grammarPoint: GrammarPointModel

    /// A helper function to define when the + button is clicked it sets the grammar point and opens tagger
    let onTagSelected: () -> Void

    /// User interface for the GrammarPointRow page
    var body: some View {
        HStack {
            Text(grammarPoint.usage)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.primary)
                .padding(.leading, 10)
            Spacer()
            Button("", systemImage: "plus") {
                onTagSelected()
            }
            .bold()
        }
    }
}

// MARK: - Journal Entry Form

/// A Helper View for defining the format of the Journal Entry form and save functionality.
///
/// This view is allows a user to type in a title, auto jump to content, toggle a private flag for future social
/// mechanics,
/// and save a journal entry. Saving will not only add the journal entry to the database, but also any tags previously
/// set
/// in the DailyGrammarSection.
/// TODO: Need to add some kind of notification if the user is saving an entry with no tags.
/// TODO: Also want to eventually add in an AI review mechanic.
struct JournalEntrySection: View {
    /// The title of the journal entry
    @Binding var title: String

    /// The content of the journal entry
    @Binding var content: String

    /// A substring from the journal entry that the user has purposefully selected via drag gestures
    @Binding var selection: TextSelection?

    /// A flag whether to set a journal entry as private for future social mechanics (TODO: implement social mechanics)
    @Binding var isPrivate: Bool

    /// A global error message holder for writing errors to the screen (TODO: make notification popup)
    @Binding var resultMessage: String?

    /// A flag to turn off interactable user infaces while async functions are running
    @Binding var isSaving: Bool

    /// A flag to add focus bars to the box surrounding the title
    @FocusState private var isTitleFocused: Bool

    /// A flag to add focus bars to the box surrounding the content
    @FocusState private var isContentFocused: Bool

    /// The actual selected text content as a string for tagging to a grammar point
    var selectedText: String

    /// User interface for the JournalEntrySection page
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Title").font(.headline)
                TextField("Enter title", text: $title)
                    .background(
                        Rectangle()
                            .stroke(isTitleFocused ? Color.accentColor : Color.primary, lineWidth: 1),
                    )
                    .focused($isTitleFocused)
                    .onSubmit {
                        isContentFocused = true
                        isTitleFocused = false
                    }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Content").font(.headline)
                TextEditor(text: $content, selection: $selection)
                    .font(.custom("HelveticaNeue", size: 18))
                    .frame(minHeight: 150, maxHeight: .infinity)
                    .background(
                        Rectangle()
                            .stroke(isContentFocused ? Color.accentColor : Color.primary, lineWidth: 1),
                    )
                    .focused($isContentFocused)
            }

            Toggle("Private", isOn: $isPrivate)

            HStack(alignment: .firstTextBaseline) {
                Button {
                    Task {
                        await submitJournal()
                    }
                } label: {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Save").bold()
                    }
                }
                .disabled(isSaving)
                .buttonStyle(.borderedProminent)

                if let msg = resultMessage {
                    Text(msg)
                        .foregroundColor(msg.starts(with: "Error") ? .red : .green)
                        .padding(.top, 10)
                }
            }
        }
    }

    /// Journal submission caller that currently sends just the journal straight to Postgres.
    private func submitJournal() async {
        // Proceed only if not already syncing, guarantee rest of code is safe
        guard !isSaving else { return }

        isSaving = true
        resultMessage = nil

        // End function by resetting sync flag, even after error
        defer { isSaving = false }

        let result = await submitJournalEntry(title: title, content: content, isPrivate: isPrivate)
        switch result {
        case let .success(message):
            resultMessage = message
            title = ""
            content = ""
            isPrivate = false
            print("Successfully posted journal entry.")
        case let .failure(error):
            resultMessage = "Error: \(error.localizedDescription)"
            print("Failed to post journal entry:", error)
        }
    }
}

// MARK: - Previews

#Preview("Journal Entry") {
    PracticeView()
        .withPreviewGrammarStore()
    // .frame(minHeight: 550)
}

#Preview("Grammar Section Only") {
    DailyGrammarSection(
        selectedGrammarID: .constant(nil),
        showingSettingsSheet: .constant(false),
        showingTaggingSheet: .constant(false),
    )
    .withPreviewGrammarStore()
}

#Preview("Journal Section Only") {
    JournalEntrySection(
        title: .constant(""),
        content: .constant(""),
        selection: .constant(nil),
        isPrivate: .constant(false),
        resultMessage: .constant(nil),
        isSaving: .constant(false),
        selectedText: "",
    )
    .padding()
}

#Preview("Grammar Point Row") {
    let sample = GrammarPointModel(
        id: UUID(),
        context: "N3",
        usage: "〜ながら",
        meaning: "while doing",
        tags: ["simultaneous", "action"],
    )

    GrammarPointRow(
        grammarPoint: sample,
        onTagSelected: { print("Tag selected") },
    )
    .padding()
}

#Preview("Tagger - With Selection") {
    PreviewHelper.withGrammarStore { store in
        if let selectedGrammarPoint = store.randomGrammarItems.first {
            TaggerView(
                selectedGrammarID: .constant(selectedGrammarPoint.id),
                showingTaggingSheet: .constant(true),
                selectedGrammarPoint: selectedGrammarPoint,
                selectedText: "Sample selected text for preview",
            )
        } else {
            Text("No grammar points available")
        }
    }
}

#Preview("Tagger - No Selection") {
    // Preview with empty selection to test edge cases
}
