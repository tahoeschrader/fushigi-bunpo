//
//  JournalView.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import SwiftUI

struct JournalEntryView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    // Journal fields
    @State private var title = ""
    @State private var content = "Testing testing. Write your journal here. Try tagging sentences with grammar points."
    @State private var isPrivate = false
    @State private var resultMessage: String?
    @State private var isSaving = false

    // Daily Grammar UI state
    @State private var grammarPoints: [GrammarPoint] = []
    @State private var errorMessage: String?
    @State private var selectedGrammarID: GrammarPoint.ID?
    var selectedGrammarPoint: GrammarPoint? {
        grammarPoints.first(where: { $0.id == selectedGrammarID })
    }

    // Navigation state
    @FocusState private var isTitleFocused: Bool
    @FocusState private var isContentFocused: Bool
    @State private var showingSettingsSheet = false

    // Settings state
    @State private var selectedLevel: Level = .all
    @State private var selectedContext: Context = .all
    @State private var selectedFunMode: FunMode = .none
    @State private var selectedSource: SourceMode = .random

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("Today's Targeted Grammar").font(.headline)
                    Spacer()
                    Button("Settings") {
                        showingSettingsSheet = true
                    }
                }
                Divider()
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(spacing: 5) {
                            Divider()
                            ForEach(grammarPoints) { grammarPoint in
                                NavigationLink {
                                    Text("Detail for \(grammarPoint.usage)")
                                } label: {
                                    Label(grammarPoint.usage, systemImage: "moonphase.new.moon")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.primary)
                                }
                                .buttonStyle(.borderless)
                                Divider()
                            }
                        }
                        .task {
                            await loadGrammarPoints()
                        }
                        VStack(alignment: .leading) {
                            Text("Title")
                                .font(.headline)
                            TextField("Enter title", text: $title)
                                .focusBorder($isTitleFocused)
                                .focused($isTitleFocused)
                                .onSubmit {
                                    isContentFocused = true
                                }
                            Text("Content")
                                .font(.headline)
                            TextEditor(text: $content)
                                .font(.custom("HelveticaNeue", size: 18))
                                .frame(height: 150)
                                .focusBorder($isContentFocused)
                                .focused($isContentFocused)
                            Toggle("Private", isOn: $isPrivate)
                            HStack {
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
                                NavigationLink {
                                    TaggerView(journalText: content)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .padding()
                                } label: {
                                    Text("Tag").bold()
                                }
                                if let msg = resultMessage {
                                    Text(msg)
                                        .foregroundColor(msg.starts(with: "Error") ? .red : .green)
                                        .padding(.top, 10)
                                }
                            }
                        }
                    }
                    .padding()
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .padding(.horizontal)
            .padding(.top)
            .sheet(isPresented: $showingSettingsSheet) {
                GrammarSettingsView(
                    selectedLevel: $selectedLevel,
                    selectedContext: $selectedContext,
                    selectedFunMode: $selectedFunMode,
                    selectedSource: $selectedSource,
                    onRefresh: {},
                )
            }
        }
    }

    private func submitJournal() async {
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

    func loadGrammarPoints() async {
        let result = await fetchGrammarPointsLimited()
        switch result {
        case let .success(points):
            grammarPoints = points
            errorMessage = nil
        case let .failure(error):
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    JournalEntryView()
}
