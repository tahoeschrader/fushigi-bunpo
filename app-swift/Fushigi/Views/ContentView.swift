//
//  ContentView.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import SwiftData
import SwiftUI

enum Page: String, Identifiable, CaseIterable {
    case grammar = "Grammar"
    case history = "History"
    case journal = "Journal"
    case training = "Training"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .grammar: "book"
        case .history: "fossil.shell"
        case .journal: "pencil"
        case .training: "gamecontroller.fill"
        }
    }

    @ViewBuilder
    var view: some View {
        switch self {
        case .grammar:
            GrammarView()
        case .history:
            HistoryView()
        case .journal:
            JournalView()
        case .training:
            GameView()
        }
    }
}

struct ContentView: View {
    @State private var selectedPage: Page? = .journal
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    var body: some View {
        if isCompact {
            TabView(selection: $selectedPage) {
                ForEach(Page.allCases) { page in
                    page.view
                        .tabItem {
                            Label(page.rawValue, systemImage: page.icon)
                        }
                        .tag(page)
                }
            }
        } else {
            NavigationSplitView {
                List(Page.allCases, selection: $selectedPage) { page in
                    NavigationLink(value: page) {
                        Label(page.rawValue, systemImage: page.icon)
                    }
                }
                .navigationSplitViewColumnWidth(min: 180, ideal: 200)
                .navigationTitle("Fushigi")
            }
            detail: {
                if let selectedPage {
                    selectedPage.view
                } else {
                    Text("Select a page. Put a logo here. Idk")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
