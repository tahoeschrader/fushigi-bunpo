//
//  ContentView.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import SwiftData
import SwiftUI

enum Page: String, Identifiable, CaseIterable {
    case practice = "Practice"
    case history = "History"
    case grammar = "Reference"
    case training = "Training"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .practice: "pencil"
        case .history: "fossil.shell"
        case .grammar: "book"
        case .training: "gamecontroller.fill"
        }
    }

    @ViewBuilder
    var view: some View {
        switch self {
        case .practice:
            PracticeView()
        case .history:
            HistoryView()
        case .grammar:
            GrammarView()
        case .training:
            GameView()
        }
    }
}

struct ContentView: View {
    @State private var selectedPage: Page? = .practice
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
                    Text("Error... not sure how this happened.")
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
        .withPreviewGrammarStore()
}
