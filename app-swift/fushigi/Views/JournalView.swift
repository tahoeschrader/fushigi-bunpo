//
//  JournalView.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import SwiftUI

struct JournalView: View {
    @State private var title = ""
    @State private var content = ""
    @State private var isPrivate = false
    @State private var resultMessage: String?
    @State private var isSaving = false
    @State private var isGrammarExpanded: Bool = false
    @State private var isTaggingExpanded: Bool = false

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 20) {

                DisclosureGroup("Today's Targeted Grammar", isExpanded: $isGrammarExpanded) {
                    ContentUnavailableView {
                        Label("5 Grammar Points", systemImage: "lightbulb")
                    } description: {
                        Text("Have some sort of setting for SRS-based and settings-based.")
                    }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    HStack(){
                        Button(action: {
                            Task {
                                await submitJournal()
                            }
                        }) {
                            if isSaving {
                                ProgressView()
                            } else {
                                Text("Save")
                                    .bold()
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
                DisclosureGroup("Sentence Tagging", isExpanded: $isTaggingExpanded) {
                    ContentUnavailableView {
                        Label("Sentence Tagging", systemImage: "lightbulb")
                    } description: {
                        Text("Put some kind of tool here that will help you tag sentences with the grammar point listed above that you used. Check boxes? Color coding?")
                    }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding()
        }
    }

    private func submitJournal() async {
        isSaving = true
        resultMessage = nil
        let result = await submitJournalEntry(title: title, content: content, isPrivate: isPrivate)
        switch result {
            case .success(let message):
                resultMessage = message
                title = ""
                content = ""
                isPrivate = false
            case .failure(let error):
                resultMessage = "Error: \(error.localizedDescription)"
        }
        isSaving = false
    }
}

#Preview {
    JournalView()
}
