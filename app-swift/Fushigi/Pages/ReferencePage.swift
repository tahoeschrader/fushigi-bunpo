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

    /// Current database state from data synchronization operations
    var dataState: DataState {
        grammarStore.dataState
    }

    // MARK: - Main View

    var body: some View {
        Group {
            switch dataState {
            case .syncError, .postgresConnectionError:
                dataState.contentUnavailableView {
                    await grammarStore.refresh()
                }
            case .emptyData:
                dataState.contentUnavailableView {
                    Task {
                        searchText = ""
                        await grammarStore.refresh()
                    }
                }
            case .networkLoading:
                dataState.contentUnavailableView {}
            case .normal:
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
        .sheet(isPresented: $showingInspector) {
            if let selectedGrammarPoint {
                DetailedGrammar(
                    isPresented: $showingInspector,
                    selectedGrammarID: $selectedGrammarID,
                    grammarPoint: selectedGrammarPoint,
                )
                .presentationDetents([.medium, .large], selection: .constant(.medium))
            } else {
                // Graceful handling of selection edge cases
                ContentUnavailableView {
                    Label("Selection Cleared", systemImage: "xmark.circle")
                } description: {
                    Text("Selection cleared. Choose another item to view details.")
                } actions: {
                    Button("Dismiss") {
                        showingInspector = false
                    }
                }
                .presentationDetents([.medium])
            }
        }
        .background {
            LinearGradient(
                colors: [.mint.opacity(0.2), .purple.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing,
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Previews

#Preview("Normal State") {
    ReferencePage(searchText: .constant(""))
        .withPreviewStores()
        .withPreviewNavigation()
}

#Preview("With Search Results") {
    ReferencePage(searchText: .constant("Hello"))
        .withPreviewStores()
        .withPreviewNavigation()
}

#Preview("No Search Results") {
    ReferencePage(searchText: .constant("nonexistent"))
        .withPreviewStores()
        .withPreviewNavigation()
}

#Preview("Error State") {
    ReferencePage(searchText: .constant(""))
        .withPreviewStores(mode: .syncError)
        .withPreviewNavigation()
}

#Preview("Empty Database") {
    ReferencePage(searchText: .constant(""))
        .withPreviewStores(mode: .emptyData)
        .withPreviewNavigation()
}
