//
//  TaggerView.swift
//  Fushigi
//
//  Created by Tahoe Schrader on 2025/08/13.
//

import SwiftUI

struct TestGrammarPoint: Identifiable, Hashable {
    let id: UUID = .init()
    let usage: String
}

struct TaggedSentence: Identifiable, Hashable {
    let id = UUID()
    let text: String
    var taggedGrammarPoint: UUID?
}

struct TaggerView: View {
    let journalText: String
    @State private var sentences: [TaggedSentence] = []
    @State private var selectedSentenceID: UUID?
    @State private var selectedGrammarID: UUID?
    @State private var grammarPoints: [TestGrammarPoint] = [
        TestGrammarPoint(usage: "～たら"),
        TestGrammarPoint(usage: "～ながら"),
        TestGrammarPoint(usage: "～ている"),
        TestGrammarPoint(usage: "～かもしれない"),
        TestGrammarPoint(usage: "～ように"),
    ]

    // Computed property for selected sentence index
    private var selectedSentenceIndex: Int? {
        guard let id = selectedSentenceID else { return nil }
        return sentences.firstIndex { $0.id == id }
    }

    private var selectedGrammarIndex: Int? {
        guard let id = selectedGrammarID else { return nil }
        return grammarPoints.firstIndex { $0.id == id }
    }

    @State private var selectedSentenceIndexes: Set<Int> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button("Add tag") {
                // add to database and clear set variables
                // show a success message
                selectedGrammarID = nil
                selectedSentenceID = nil
                selectedSentenceIndexes = []
            }
            .buttonStyle(.bordered)

            // Choose grammar point to make tag
            VStack(alignment: .leading) {
                Text("Select a grammar point:").bold()
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(grammarPoints) { gp in
                            let isTagged = gp.id == selectedGrammarID
                            Button {
                                selectedGrammarID = gp.id
                            } label: {
                                Text(gp.usage)
                                    .padding(8)
                                    .background(isTagged ? Color.green.opacity(0.7) : Color.gray.opacity(0.2))
                                    .foregroundColor(isTagged ? .white : .primary)
                                    .cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.vertical, 5)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(sentences) { sentence in
                        Button {
                            selectedSentenceID = sentence.id
                            toggleSentence()
                        } label: {
                            let idx: Int? = sentences.firstIndex(where: { $0.id == sentence.id })
                            let isSelected: Bool = idx.map { selectedSentenceIndexes.contains($0) } ?? false

                            Text(sentence.text)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(8)
                                .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
                                .cornerRadius(6)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
        }.task {
            splitIntoSentences()
        }
    }

    private func splitIntoSentences() {
        let separators = CharacterSet(charactersIn: ".!?。！？")
        let parts = journalText
            .components(separatedBy: separators)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        var newSentences: [TaggedSentence] = []
        for part in parts {
            if let existing = sentences.first(where: { $0.text == part }) {
                newSentences.append(existing)
            } else {
                newSentences.append(TaggedSentence(text: part))
            }
        }

        sentences = newSentences
        selectedGrammarID = nil
        selectedSentenceID = nil
        selectedSentenceIndexes = []
    }

    private func toggleSentence() {
        if let idx = selectedSentenceIndex {
            if selectedSentenceIndexes.contains(idx) {
                selectedSentenceIndexes.remove(idx)
            } else {
                selectedSentenceIndexes.insert(idx)
            }
        }
    }
}

#Preview {
    TaggerView(journalText: "Testing testing. 123. Testing Testing.")
}
