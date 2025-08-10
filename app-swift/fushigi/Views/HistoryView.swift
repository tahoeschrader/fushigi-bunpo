//
//  HistoryView.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import SwiftUI

struct HistoryView: View {
    @State private var searchText = ""
    @State private var journalEntries: [JournalEntryInDB] = []
    @State private var errorMessage: String?
    @State private var expanded: Set<Int> = []


    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                if let error = errorMessage {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Image(systemName: "magnifyingglass")
                    TextField("Type to search...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: searchText) {
                            // nothing right now
                        }
                }
            }
            .padding()
            .background()
            
            Divider()
            if filteredEntries.isEmpty {
                ContentUnavailableView.search
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background()
            } else {
                List {
                    ForEach(filteredEntries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Button {
                                toggleExpanded(for: entry.id)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(entry.title)
                                            .font(.headline)
                                        Text(entry.created_at.formatted())
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: expanded.contains(entry.id) ? "chevron.down" : "chevron.right")
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if expanded.contains(entry.id) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(entry.content)
                                        .font(.body)
                                        .padding(.top, 4)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Grammar Points:")
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                        Text("• (placeholder) ～てしまう")
                                        Text("• (placeholder) ～わけではない")
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("AI Feedback:")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("(placeholder) Try to avoid passive constructions.")
                                    }
                                }
                                .padding(.leading)
                                .padding(.top, 4)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteEntry)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .task {
            let result = await fetchJournalEntries()
            switch result {
            case .success(let entries):
                journalEntries = entries
                errorMessage = nil
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }

    private func toggleExpanded(for id: Int) {
        if expanded.contains(id) {
            expanded.remove(id)
        } else {
            expanded.insert(id)
        }
    }

    private func deleteEntry(at offsets: IndexSet) {
        for index in offsets {
            let deletedEntry = filteredEntries[index]
            print("Pretending to delete: \(deletedEntry.title)")
            if let realIndex = journalEntries.firstIndex(where: { $0.id == deletedEntry.id }) {
                journalEntries.remove(at: realIndex)
            }
        }
    }

    var filteredEntries: [JournalEntryInDB] {
        if searchText.isEmpty {
            return journalEntries
        } else {
            return journalEntries.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

}

#Preview {
    HistoryView()
}
