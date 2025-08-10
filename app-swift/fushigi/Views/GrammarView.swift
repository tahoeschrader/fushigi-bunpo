//
//  GrammarView.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import SwiftUI

struct GrammarView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    @State private var searchText: String = ""
    @State private var grammarPoints: [GrammarPoint] = []
    @State private var errorMessage: String?
    @State private var selectedGrammarID: GrammarPoint.ID?
    var selectedGrammarPoint: GrammarPoint? {
        grammarPoints.first(where: { $0.id == selectedGrammarID })
    }

    @State private var showingInspector: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if errorMessage != nil {
                    ContentUnavailableView {
                        Label("Error", systemImage: "error")
                    } description: {
                        Text(errorMessage!)
                    }
                } else if filteredPoints.isEmpty {
                    ContentUnavailableView.search
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background()
                } else {
                    TableView(
                        grammarPoints: filteredPoints,
                        selectedGrammarID: $selectedGrammarID,
                        showingInspector: $showingInspector,
                        isCompact: isCompact
                    )
                    .inspector(isPresented: $showingInspector) {
                        if let thisGrammarPoint = selectedGrammarPoint {
                            InspectorView(
                                grammarPoint: thisGrammarPoint,
                                isPresented: $showingInspector,
                                isCompact: isCompact
                            )
                        } else {
                            LegendView(isCompact: isCompact, isPresented: $showingInspector)
                                .presentationDetents([.fraction(0.5), .large])
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Type to search...")
            .toolbar {
                ToolbarItem {
                    Menu("Options") {
                        Button("Deselect", action: { selectedGrammarID = nil })
                            .disabled(selectedGrammarID == nil)
                        Divider()
                        Button("Delete", role: .destructive, action: { /* TODO: */ })
                            .disabled(true)
                        Button("Edit", action: { /* TODO: */ })
                            .disabled(true)
                        Divider()
                        Button("Add", action: { /* TODO: */ })
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
            .task {
                let result = await fetchGrammarPoints()
                switch result {
                case let .success(points):
                    grammarPoints = points
                    errorMessage = nil
                case let .failure(error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    var filteredPoints: [GrammarPoint] {
        if searchText.isEmpty {
            return grammarPoints
        } else {
            return grammarPoints.filter {
                $0.usage.localizedCaseInsensitiveContains(searchText) ||
                    $0.meaning.localizedCaseInsensitiveContains(searchText) ||
                    $0.level.localizedCaseInsensitiveContains(searchText) ||
                    $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }
}

#Preview {
    GrammarView()
}
