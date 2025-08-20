//
//  HistoryPage.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import SwiftUI

struct HistoryPage: View {
    /// Responsive layout detection for adaptive navigation structure
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @State private var journalEntries: [JournalEntryInDB] = []
    @State private var errorMessage: String?
    @State private var expanded: Set<UUID> = []

    @Binding var searchText: String

    /// Determines whether to use compact navigation patterns (tabs vs split view)
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    var body: some View {
        ScrollView {
            if errorMessage != nil {
                ContentUnavailableView {
                    Label("Error", systemImage: "exclamationmark.warninglight.fill")
                } description: {
                    Text(errorMessage!)
                }
            } else if filteredEntries.isEmpty {
                ContentUnavailableView.search
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background()
            } else {
                LazyVStack(alignment: .leading) {
                    ForEach(filteredEntries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Button {
                                toggleExpanded(for: entry.id)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(entry.title)
                                            .font(.headline)
                                        Text(entry.createdAt.formatted())
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: expanded.contains(entry.id) ?
                                        "chevron.down" : "chevron.right")
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
                .padding()
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .task {
            let result = await fetchJournalEntries()
            switch result {
            case let .success(entries):
                journalEntries = entries
                errorMessage = nil
            case let .failure(error):
                errorMessage = error.localizedDescription
            }
        }
        .navigationTitle("History")
        .toolbar {
            Menu("Sort", systemImage: "arrow.up.arrow.down") {
                Button("Newest First") { /* TODO: Implement sorting */ }
                Button("Oldest First") { /* TODO: Implement sorting */ }
                Button("By Title") { /* TODO: Implement sorting */ }
            }

            Menu("Filter", systemImage: "line.3.horizontal.decrease.circle") {
                Button("All Entries") { /* TODO: Implement filtering */ }
                Button("Private Only") { /* TODO: Implement filtering */ }
                Button("Public Only") { /* TODO: Implement filtering */ }
                Divider()
                Button("This Week") { /* TODO: Implement filtering */ }
                Button("This Month") { /* TODO: Implement filtering */ }
            }
        }
    }

    private func toggleExpanded(for id: UUID) {
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
            journalEntries
        } else {
            journalEntries.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                    $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

#Preview {
    HistoryPage(searchText: .constant(""))
        .withPreviewNavigation()
}
