//
//  JournalEntryView.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import SwiftUI

struct JournalEntryView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var grammarStore: GrammarStore

    // Navigation state
    @State private var showingSettingsSheet = false
    @State private var showingTaggingSheet = false

    // Settings state
    @State private var selectedLevel: Level = .all
    @State private var selectedContext: Context = .all
    @State private var selectedFunMode: FunMode = .none
    @State private var selectedSource: SourceMode = .random

    // Data state
    @State private var selectedGrammarID: UUID?
    @State private var selection: TextSelection?

    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    // MARK: - Main View

    var body: some View {
        if isCompact {
            // Need the navigation stack for compact since it's instantiated with TabView
            NavigationStack { journalContentView }
                .sheet(isPresented: $showingSettingsSheet) { settingsView }
                .sheet(isPresented: $showingTaggingSheet) { taggerView }
        } else {
            journalContentView
                .inspector(isPresented: $showingSettingsSheet) { settingsView }
                .inspector(isPresented: $showingTaggingSheet) { taggerView }
        }
    }

    // MARK: - Extracted View Builders

    @ViewBuilder
    private var journalContentView: some View {
        JournalContentView(
            selectedGrammarID: $selectedGrammarID,
            showingSettingsSheet: $showingSettingsSheet,
            showingTaggingSheet: $showingTaggingSheet,
            selectedSource: $selectedSource,
            selection: $selection,
        )
    }

    @ViewBuilder
    private var settingsView: some View {
        GrammarSettingsView(
            selectedLevel: $selectedLevel,
            selectedContext: $selectedContext,
            selectedFunMode: $selectedFunMode,
            selectedSource: $selectedSource,
        )
    }

    @ViewBuilder
    private var taggerView: some View {
        if let selectedGrammarPoint = grammarStore.getRandomGrammarPoint(id: selectedGrammarID) {
            TaggerView(
                selectedText: $selection,
                selectedGrammarID: $selectedGrammarID,
                showingTaggingSheet: $showingTaggingSheet,
                selectedGrammarPoint: selectedGrammarPoint,
            )
        }
    }
}

// MARK: - Tagger View

struct TaggerView: View {
    @Binding var selectedText: TextSelection?
    @Binding var selectedGrammarID: UUID?
    @Binding var showingTaggingSheet: Bool
    var selectedGrammarPoint: GrammarPointModel?

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
            Text("blahblahblah").italic().padding(.leading, 10)
            Text("Selected sentence(s):").bold()
            Text("blahblahblah").italic().padding(.leading, 10)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// MARK: - Journal Content View

struct JournalContentView: View {
    @EnvironmentObject var grammarStore: GrammarStore
    @Binding var selectedGrammarID: UUID?
    @Binding var showingSettingsSheet: Bool
    @Binding var showingTaggingSheet: Bool
    @Binding var selectedSource: SourceMode
    @Binding var selection: TextSelection?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            DailyGrammarSection(
                selectedGrammarID: $selectedGrammarID,
                showingSettingsSheet: $showingSettingsSheet,
                showingTaggingSheet: $showingTaggingSheet,
            )

            JournalEntryForm(selection: $selection)
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

struct DailyGrammarSection: View {
    @EnvironmentObject var grammarStore: GrammarStore
    @Binding var selectedGrammarID: UUID?
    @Binding var showingSettingsSheet: Bool
    @Binding var showingTaggingSheet: Bool

    private var grammarPoints: [GrammarPointModel] {
        grammarStore.getRandomGrammarPoints()
    }

    private var errorMessage: String? {
        grammarStore.syncError?.localizedDescription
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Today's Targeted Grammar").font(.headline)
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

struct GrammarPointRow: View {
    let grammarPoint: GrammarPointModel
    let onTagSelected: () -> Void

    var body: some View {
        Button {
            onTagSelected()
        } label: {
            HStack {
                Text(grammarPoint.usage)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.primary)
                    .padding(.leading, 10)
                Spacer()
                Button {
                    onTagSelected()
                } label: {
                    Label("", systemImage: "plus")
                }
                .bold()
                .buttonStyle(.plain)
            }
        }
        .buttonStyle(.borderless)
    }
}

// MARK: - Journal Entry Form

struct JournalEntryForm: View {
    @Binding var selection: TextSelection?

    @State private var title = ""
    @State private var content = ""
    @State private var isPrivate = false
    @State private var resultMessage: String?
    @State private var isSaving = false

    @FocusState private var isTitleFocused: Bool
    @FocusState private var isContentFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Title").font(.headline)
                TextField("Enter title", text: $title, selection: $selection)
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
                TextEditor(text: $content)
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

    private func submitJournal() async {
        // TODO: fatal crash on iOS
        isSaving = true
        resultMessage = nil
        let result = await submitJournalEntry(title: title, content: content, isPrivate: isPrivate)
        switch result {
        case let .success(message):
            resultMessage = message
            title = ""
            content = ""
            isPrivate = false
        case let .failure(error):
            resultMessage = "Error: \(error.localizedDescription)"
        }
        isSaving = false
    }
}

// MARK: - Previews

#Preview("Journal Entry") {
    JournalEntryView()
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

#Preview("Journal Form Only") {
    let mockSelection = TextSelection(insertionPoint: "Testing testing.".startIndex)

    return JournalEntryForm(selection: .constant(mockSelection))
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

#Preview("Tagger") {
    let mockSelection: TextSelection? = TextSelection(insertionPoint: "Testing testing. 123.".startIndex)

    PreviewHelper.withGrammarStore { store in
        let selectedGrammarPoint = store.randomGrammarItems.first!
        TaggerView(
            selectedText: .constant(mockSelection),
            selectedGrammarID: .constant(selectedGrammarPoint.id),
            showingTaggingSheet: .constant(true),
            selectedGrammarPoint: selectedGrammarPoint,
        )
    }
}
