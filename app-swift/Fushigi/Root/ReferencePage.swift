//
//  ReferencePage.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import SwiftUI

/// Comprehensive grammar reference interface providing searchable access to grammar points.
///
/// This view presents the complete grammar database in an organized, searchable format
/// that adapts to different screen sizes and interaction paradigms. Users can explore
/// grammar points through filtering, search for specific patterns or meanings, and
/// access detailed information through context-sensitive inspection interfaces.
///
/// The view maintains responsive design principles, automatically adjusting between
/// compact table layouts for mobile devices and expanded multi-column displays for
/// larger screens, while preserving full functionality across all form factors.
struct ReferencePage: View {
    /// Responsive layout detection for adaptive table presentation
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    /// Centralized grammar data repository with synchronization capabilities
    @EnvironmentObject var grammarStore: GrammarStore

    /// Currently selected grammar point for detailed examination
    @State private var selectedGrammarID: UUID?

    /// Controls the settings sheet that allows users to configure practice content preferences
    @State private var showingSettings: Bool = false

    /// Controls detailed grammar point inspection interface visibility
    @State private var showingInspector: Bool = false

    /// Search query text coordinated with parent navigation structure
    @Binding var searchText: String

    /// Determines layout strategy based on available horizontal space
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    /// Dynamically filtered grammar points based on current search criteria.
    ///
    /// Applies real-time filtering to the complete grammar database, searching
    /// across usage patterns, meanings, tags, and contextual information to
    /// provide relevant results that match user queries.
    var grammarPoints: [GrammarPointModel] {
        grammarStore.filterGrammarPoints(containing: searchText)
    }

    /// Currently selected grammar point object for detailed display.
    ///
    /// Retrieves the complete grammar point data associated with the current
    /// selection, enabling detailed inspection and contextual information display.
    var selectedGrammarPoint: GrammarPointModel? {
        grammarStore.getGrammarPoint(id: selectedGrammarID)
    }

    /// Current error state from data synchronization operations.
    ///
    /// Captures and presents user-friendly error messages for various failure
    /// scenarios including network issues, database problems, and data corruption.
    var errorMessage: String? {
        grammarStore.syncError?.localizedDescription
    }

    // MARK: - Main View

    var body: some View {
        VStack(spacing: 0) {
            // Error state with actionable recovery options
            if let errorMessage {
                ContentUnavailableView {
                    Label("Grammar Data Unavailable", systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                } description: {
                    VStack(spacing: 8) {
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
                            "The grammar database appears to be empty. Try refreshing the data or check your connection.",
                        )
                    } else {
                        VStack(spacing: 4) {
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
                .background()

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
        .animation(.easeInOut(duration: 0.3), value: grammarPoints.count)
        .animation(.easeInOut(duration: 0.3), value: errorMessage != nil)
        .navigationTitle("Grammar Reference")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
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
                InspectorView(
                    grammarPoint: selectedGrammarPoint,
                    isPresented: $showingInspector,
                    selectedGrammarID: $selectedGrammarID,
                    isCompact: isCompact,
                )
                .inspectorColumnWidth(min: 250, ideal: 300, max: 400)
                .presentationDetents([.fraction(0.25), .medium])
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
                .padding()
                .presentationDetents([.fraction(0.2)])
            }
        }
    }
}

// MARK: Previews

#Preview("Grammar View - Normal State") {
    ReferencePage(searchText: .constant(""))
        .withPreviewGrammarStore()
        .withPreviewNavigation()
}

#Preview("Grammar View - With Search Results") {
    ReferencePage(searchText: .constant("ながら"))
        .withPreviewGrammarStore()
        .withPreviewNavigation()
}

#Preview("Grammar View - No Search Results") {
    ReferencePage(searchText: .constant("nonexistent"))
        .withPreviewGrammarStore()
        .withPreviewNavigation()
}

#Preview("Grammar View - Error State") {
    ReferencePage(searchText: .constant(""))
        .withPreviewGrammarStore(mode: .syncError)
        .withPreviewNavigation()
}

#Preview("Grammar View - Empty Database") {
    ReferencePage(searchText: .constant(""))
        .withPreviewGrammarStore(mode: .emptyData)
        .withPreviewNavigation()
}

#Preview("Grammar View - Compact Layout") {
    ReferencePage(searchText: .constant(""))
        .withPreviewGrammarStore()
        .withPreviewNavigation()
}

#Preview("Grammar View - Regular Layout") {
    ReferencePage(searchText: .constant(""))
        .withPreviewGrammarStore()
        .withPreviewNavigation()
}
