//
//  ContentView.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import SwiftUI
import SwiftData

enum Page: String, Identifiable, CaseIterable {
    case home = "Home"
    case grammar = "Grammar"
    case history = "History"
    case journal = "Journal"

    var id: String { rawValue }
    var icon: String {
        switch self {
            case .home: return "house"
            case .grammar: return "book"
            case .history: return "fossil.shell"
            case .journal: return "pencil"
        }
    }
}

struct ContentView: View {
    @State private var selectedPage: Page? = .home

    var body: some View {
        NavigationSplitView {
            List(Page.allCases, selection: $selectedPage) { page in
                NavigationLink(value: page) {
                    Label(page.rawValue, systemImage: page.icon)
                }
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .navigationTitle("Fushigi")
        } detail: {
            switch selectedPage {
            case .home:
                HomeView()
            case .grammar:
                GrammarView()
            case .history:
                HistoryView()
            case .journal:
                JournalView()
            case .none:
                Text("Select a page")
            }
        }
    }
}

#Preview {
    ContentView()
}
