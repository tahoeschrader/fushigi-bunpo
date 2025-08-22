//
//  ReferencePage.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import SwiftUI

// MARK: - Reference Page

/// Searchable grammar reference interface with detailed grammar point inspection
struct ReferencePage: View {
    /// Responsive layout detection for adaptive table presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    /// Centralized grammar data repository with synchronization capabilities
    @EnvironmentObject var grammarStore: GrammarStore

    /// Currently selected grammar point for detailed examination
    @State private var selectedGrammarID: UUID?

    /// Controls the settings sheet for practice content preferences
    @State private var showingSettings: Bool = false

    /// Controls detailed grammar point inspection interface visibility
    @State private var showingInspector: Bool = false

    /// Search query text coordinated with parent navigation structure
    @Binding var searchText: String

    /// Determines layout strategy based on available horizontal space
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    /// Filtered grammar points based on current search criteria
    var grammarPoints: [GrammarPointLocal] {
        grammarStore.filterGrammarPoints(containing: searchText)
    }

    /// Currently selected grammar point object for detailed display
    var selectedGrammarPoint: GrammarPointLocal? {
        grammarStore.getGrammarPoint(id: selectedGrammarID)
    }

    /// Current error state from data synchronization operations
    var errorMessage: String? {
        grammarStore.syncError?.localizedDescription
    }

    // MARK: - Main View

    var body: some View {
        Group {
            // TODO: simplify error checking with some sort of computed property
            if let errorMessage {
                ContentUnavailableView {
                    Label("Grammar Data Unavailable", systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                } description: {
                    VStack(spacing: UIConstants.Spacing.row) {
                        Text("Unable to load grammar reference data")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                } actions: {
                    Button("Retry Connection", systemImage: "arrow.clockwise") {
                        Task {
                            await grammarStore.refresh()
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Check Network Settings", systemImage: "wifi") {
                        // TODO: Open network settings or provide guidance
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Empty search results with helpful guidance
            } else if grammarPoints.isEmpty {
                ContentUnavailableView {
                    Label("No Grammar Points Found", systemImage: "magnifyingglass")
                } description: {
                    if searchText.isEmpty {
                        Text(
                            "The grammar database appears to be empty." +
                                "Try refreshing the data or check your connection.",
                        )
                    } else {
                        VStack(spacing: UIConstants.Spacing.tightRow) {
                            Text("No results for \"\(searchText)\"")
                                .font(.headline)
                            Text("Try adjusting your search terms or browsing all grammar points")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                } actions: {
                    if !searchText.isEmpty {
                        Button("Clear Search") {
                            searchText = ""
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    Button("Refresh Data") {
                        Task {
                            await grammarStore.refresh()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Main grammar table with responsive layout
            } else {
                GrammarTable(
                    selectedGrammarID: $selectedGrammarID,
                    showingInspector: $showingInspector,
                    grammarPoints: grammarPoints,
                    isCompact: isCompact,
                    onRefresh: {
                        await grammarStore.refresh()
                    },
                )
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Menu("Options", systemImage: "ellipsis.circle") {
                    Button("Import Grammar", systemImage: "square.and.arrow.down") {
                        // TODO: Implement grammar import functionality
                    }
                    .disabled(true)

                    Button("Export Study List", systemImage: "square.and.arrow.up") {
                        // TODO: Implement grammar export functionality
                    }
                    .disabled(true)

                    Divider()

                    Button("Delete All", systemImage: "trash", role: .destructive) {
                        // TODO: Implement bulk delete with confirmation
                    }
                    .disabled(true)
                }
            }
        }
        .inspector(isPresented: $showingInspector) {
            if let selectedGrammarPoint {
                DetailedGrammar(
                    grammarPoint: selectedGrammarPoint,
                    isPresented: $showingInspector,
                    selectedGrammarID: $selectedGrammarID,
                    isCompact: isCompact,
                )
                .presentationDetents([.fraction(1 / 4), .medium])
            } else {
                // Graceful handling of selection edge cases
                ContentUnavailableView {
                    Label("Selection Cleared", systemImage: "xmark.circle")
                } description: {
                    Text("The grammar point selection was cleared. Choose another item to view details.")
                } actions: {
                    Button("Close Inspector") {
                        showingInspector = false
                    }
                }
                .presentationDetents([.fraction(1 / 4)])
            }
        }
    }
}

// MARK: - Previews

#Preview("Normal State") {
    ReferencePage(searchText: .constant(""))
        .withPreviewGrammarStore()
        .withPreviewNavigation()
}

#Preview("With Search Results") {
    ReferencePage(searchText: .constant("Hello"))
        .withPreviewGrammarStore()
        .withPreviewNavigation()
}

#Preview("No Search Results") {
    ReferencePage(searchText: .constant("nonexistent"))
        .withPreviewGrammarStore()
        .withPreviewNavigation()
}

#Preview("Error State") {
    ReferencePage(searchText: .constant(""))
        .withPreviewGrammarStore(mode: .syncError)
        .withPreviewNavigation()
}

#Preview("Empty Database") {
    ReferencePage(searchText: .constant(""))
        .withPreviewGrammarStore(mode: .emptyData)
        .withPreviewNavigation()
}
