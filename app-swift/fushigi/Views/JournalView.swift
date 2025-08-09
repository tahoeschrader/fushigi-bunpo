//
//  JournalView.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import SwiftUI

struct JournalView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    // Journal fields
    @State private var title = ""
    @State private var content = ""
    @State private var isPrivate = false
    @State private var resultMessage: String?
    @State private var isSaving = false

    // Grammar UI state
    @State private var isGrammarExpanded = false
    @State private var isTaggingExpanded = false
    @State private var grammarPoints: [GrammarPoint] = []
    @State private var errorMessage: String?
    @State private var selectedGrammarID: GrammarPoint.ID?
    var selectedGrammarPoint: GrammarPoint? {
        grammarPoints.first(where: { $0.id == selectedGrammarID })
    }

    @State private var showingInspector = false

    // Settings state
    @State private var selectedLevel: Level = .all
    @State private var selectedContext: Context = .all
    @State private var selectedFunMode: FunMode = .none
    @State private var selectedSource: SourceMode = .random
    @State private var showingSettingsSheet = false

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Today's Targeted Grammar").font(.headline)
                        Spacer()
                        Button("Settings") {
                            showingSettingsSheet = true
                        }
                    }
                    TableView(
                        grammarPoints: grammarPoints,
                        selectedGrammarID: $selectedGrammarID,
                        showingInspector: $showingInspector,
                        isCompact: isCompact
                    ).frame(minHeight: 250)
                }
                .task {
                    let result = await fetchGrammarPointsLimited()
                    switch result {
                    case let .success(points):
                        grammarPoints = points
                        errorMessage = nil
                    case let .failure(error):
                        errorMessage = error.localizedDescription
                    }
                }
                Divider()

                VStack(alignment: .leading) {
                    Text("Title")
                        .font(.headline)
                    TextField("Enter title", text: $title)
                        .textFieldStyle(.roundedBorder)
                    Text("Content")
                        .font(.headline)
                    TextEditor(text: $content)
                        .font(.custom("HelveticaNeue", size: 18))
                        .frame(height: 150)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5))
                        )
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

                        if let msg = resultMessage {
                            Text(msg)
                                .foregroundColor(msg.starts(with: "Error") ? .red : .green)
                                .padding(.top, 10)
                        }
                    }
                }

                Divider()

                ContentUnavailableView {
                    Label("Sentence Tagging", systemImage: "lightbulb")
                } description: {
                    Text("Put some kind of tool here that will help you tag sentences with the grammar point listed above that you used. Check boxes? Color coding?")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding()
        }
        .sheet(isPresented: $showingSettingsSheet) {
            GrammarSettingsView(
                selectedLevel: $selectedLevel,
                selectedContext: $selectedContext,
                selectedFunMode: $selectedFunMode,
                selectedSource: $selectedSource,
                onRefresh: {
                    // TBD: refresh action
                }
            )
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
}

#Preview {
    JournalView()
}
