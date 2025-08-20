//
//  ContentView.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import SwiftData
import SwiftUI

/// Main application container managing navigation structure and coordinating between primary app sections.
///
/// This view orchestrates the overall navigation experience, dynamically adapting between
/// tab-based navigation (compact layouts) and split-view navigation (regular layouts) while
/// managing shared state like search functionality. It serves as the coordination point
/// for toolbar configuration and ensures consistent navigation patterns across platforms.
///
/// The view automatically handles responsive layout transitions and maintains proper
/// navigation context for child views, enabling seamless user experiences across
/// iPhone, iPad, and macOS deployment targets.
struct ContentView: View {
    /// Responsive layout detection for adaptive navigation structure
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    /// Currently active application section, coordinating tab/sidebar selection
    @State private var selectedPage: Page? = .practice

    /// Shared search query state for views that support content filtering
    // Define here because can eventually make a global search
    @State private var searchText: String = ""

    /// Determines whether to use compact navigation patterns (tabs vs split view)
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    /// Toggle for which pages have valid search mechanics
    private var shouldShowSearch: Bool {
        selectedPage?.supportsSearch ?? false
    }

    // MARK: - Main View

    var body: some View {
        if isCompact {
            NavigationAsTabs
                .tabBarMinimizeOnScrollIfAvailable()
        } else {
            NavigationAsSplitView
        }
    }

    /// Tab-based navigation optimized for compact layouts (iPhone portrait, small windows)
    @ViewBuilder
    private var NavigationAsTabs: some View {
        TabView(selection: $selectedPage) {
            Tab(Page.practice.id, systemImage: Page.practice.icon, value: .practice) {
                NavigationStack {
                    decoratedView(for: .practice)
                }
            }

            Tab(Page.history.id, systemImage: Page.history.icon, value: .history) {
                NavigationStack {
                    decoratedView(for: .history)
                }
                .searchableIf(!isCompact, text: $searchText) // MacOS style search for iPadOS
            }

            Tab(Page.reference.id, systemImage: Page.reference.icon, value: .reference) {
                NavigationStack {
                    decoratedView(for: .reference)
                }
                .searchableIf(!isCompact, text: $searchText) // MacOS style search for iPadOS
            }

            // iOS 18+ dedicated search tab
            Tab(value: .search, role: .search) {
                NavigationStack {
                    decoratedView(for: .search)
                        .navigationTitle(Page.search.id)
                        .searchable(text: $searchText)
                }
            }
        }
    }

    /// Split view navigation optimized for regular layouts (iPad, macOS, iPhone landscape)
    @ViewBuilder
    private var NavigationAsSplitView: some View {
        NavigationSplitView {
            List(selection: $selectedPage) {
                NavigationLink(value: Page.practice) {
                    Label(Page.practice.id, systemImage: Page.practice.icon)
                }
                NavigationLink(value: Page.history) {
                    Label(Page.history.id, systemImage: Page.history.icon)
                }
                NavigationLink(value: Page.reference) {
                    Label(Page.reference.id, systemImage: Page.reference.icon)
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .navigationTitle("Fushigi")
            .searchableIf(selectedPage?.supportsSearch ?? false, text: $searchText)
        }
        detail: {
            if let selectedPage {
                decoratedView(for: selectedPage)
            } else {
                // Fallback state for navigation edge cases
                ContentUnavailableView {
                    Label("Select a Section", systemImage: "sidebar.left")
                } description: {
                    Text("Not sure why this is happening. Need to debug.")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    /// Applies appropriate navigation decorations and configurations for each app section.
    ///
    /// This method centralizes navigation setup, ensuring consistent toolbar placement,
    /// search functionality, and title configuration across all app sections. It handles
    /// the platform-specific nuances of navigation hierarchy and modifier application.
    @ViewBuilder
    private func decoratedView(for page: Page) -> some View {
        switch page {
        case .practice:
            PracticePage()
        case .history:
            HistoryPage(searchText: $searchText)
        case .reference:
            ReferencePage(searchText: $searchText)
        case .search:
            SearchPage(searchText: $searchText, selectedPage: $selectedPage)
        }
    }

    /// Enumeration of primary application sections with associated metadata.
    ///
    /// Each case represents a major functional area of the application, complete
    /// with user-facing labels and appropriate iconography for consistent
    /// navigation presentation across different interface paradigms.
    enum Page: String, Identifiable, CaseIterable {
        case practice = "Practice"
        case history = "History"
        case reference = "Reference"
        case search = "Search"

        var id: String { rawValue }

        /// System icon name appropriate for the section's primary function
        var icon: String {
            switch self {
            case .practice: "pencil.and.scribble"
            case .history: "clock.arrow.2.circlepath"
            case .reference: "books.vertical.fill"
            case .search: "magnifyingglass"
            }
        }

        var supportsSearch: Bool {
            switch self {
            case .practice: false
            case .history: true
            case .reference: true
            case .search: false
            }
        }
    }
}

struct SearchPage: View {
    @Binding var searchText: String
    @Binding var selectedPage: ContentView.Page?
    @EnvironmentObject var grammarStore: GrammarStore

    @State private var lastActiveTab: ContentView.Page = .practice

    var body: some View {
        Group {
            if searchText.isEmpty {
                ContentUnavailableView {
                    Label("Search \(lastActiveTab.rawValue)", systemImage: "magnifyingglass")
                } description: {
                    Text("Enter a term to search within \(lastActiveTab.rawValue.lowercased()) content.")
                }
            } else {
                // Just show the actual page with search applied!
                showPageWithSearch(for: lastActiveTab)
            }
        }
        .onAppear {
            if let current = selectedPage, current != .search {
                lastActiveTab = current
            }
        }
        .onChange(of: selectedPage) { _, newValue in
            if let newValue, newValue != .search {
                lastActiveTab = newValue
            }
        }
    }

    @ViewBuilder
    private func showPageWithSearch(for tab: ContentView.Page) -> some View {
        switch tab {
        case .practice:
            ReferencePage(searchText: $searchText)

        case .history:
            HistoryPage(searchText: $searchText)

        case .reference:
            ReferencePage(searchText: $searchText)

        case .search:
            // Fallback
            Text("This should not happen...")
        }
    }
}

// MARK: Previews

#Preview("Normal State") {
    ContentView()
        .withPreviewGrammarStore(mode: .normal)
}

#Preview("Empty Data State") {
    ContentView()
        .withPreviewGrammarStore(mode: .emptyData)
}

#Preview("Sync Error State") {
    ContentView()
        .withPreviewGrammarStore(mode: .syncError)
}

#Preview("Network Timeout State") {
    ContentView()
        .withPreviewGrammarStore(mode: .networkTimeout)
}

#Preview("Database Error State") {
    ContentView()
        .withPreviewGrammarStore(mode: .postgresConnectionError)
}
