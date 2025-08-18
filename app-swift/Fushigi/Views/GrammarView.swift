//
//  GrammarView.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import SwiftUI

struct GrammarView: View {
    // UIUX Parameters
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var showingInspector: Bool = false
    @State private var searchText: String = ""
    @State private var selectedGrammarID: UUID?
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    // Data
    @EnvironmentObject var grammarStore: GrammarStore
    var grammarPoints: [GrammarPointModel] {
        grammarStore.filterGrammarPoints(containing: searchText)
    }

    var selectedGrammarPoint: GrammarPointModel? {
        grammarStore.getGrammarPoint(id: selectedGrammarID)
    }

    var errorMessage: String? {
        grammarStore.syncError?.localizedDescription
    }

    var body: some View {
        // TODO: Make this more modular like JournalEntryView
        NavigationStack {
            VStack(spacing: 0) {
                if errorMessage != nil {
                    ContentUnavailableView {
                        Label("Error", systemImage: "error")
                    } description: {
                        Text(errorMessage!)
                    }
                } else if grammarPoints.isEmpty {
                    ContentUnavailableView.search
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background()
                } else {
                    TableView(
                        grammarPoints: grammarPoints,
                        selectedGrammarID: $selectedGrammarID,
                        showingInspector: $showingInspector,
                        isCompact: isCompact,
                        onRefresh: {
                            await grammarStore.refresh()
                        },
                    )
                    .inspector(isPresented: $showingInspector) {
                        if let thisGrammarPoint = selectedGrammarPoint {
                            InspectorView(
                                grammarPoint: thisGrammarPoint,
                                isPresented: $showingInspector,
                                selectedGrammarID: $selectedGrammarID,
                                isCompact: isCompact,
                            )
                        } else {
                            LegendView(
                                isCompact: isCompact,
                                isPresented: $showingInspector,
                            )
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Type to search...")
            .toolbar {
                ToolbarItem {
                    Menu("Options") {
                        Button("Delete", role: .destructive, action: {
                            // Add delete api
                        })
                        .disabled(true)
                        Button("Edit", action: {
                            // Add edit api
                        })
                        .disabled(true)
                        Divider()
                        Button("Add", action: {
                            // Add add api
                        })
                        .disabled(true)
                    }
                }
                ToolbarItem {
                    Button {
                        showingInspector.toggle()
                    } label: {
                        Label("More Info", systemImage: "sidebar.trailing")
                    }
                }
            }
        }
    }
}

#Preview {
    GrammarView()
        .withPreviewGrammarStore()
}
