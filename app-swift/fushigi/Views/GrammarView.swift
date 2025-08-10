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
    @State private var currentPage = 0
    private let pageSize = 10
    @State private var selectedGrammarID: GrammarPoint.ID?
    var selectedGrammarPoint: GrammarPoint? {
        grammarPoints.first(where: { $0.id == selectedGrammarID })
    }

    @State private var showingInspector: Bool = false
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                if let error = errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    TextField("Type to search...", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSearchFocused ? Color.accentColor.opacity(0.5) : Color.gray.opacity(0.5))
                        )
                        .onChange(of: searchText) {
                            // nothing right now
                        }
                        .focused($isSearchFocused)
                }
                Menu(content: {
                    Section {
                        Button(action: {
                            selectedGrammarID = nil
                        }) {
                            Label("Deselect", systemImage: "square.slash")
                        }.disabled(selectedGrammarID == nil)

                        Button(action: {
                            showingInspector.toggle()
                        }) {
                            Label("Show Info", systemImage: "info")
                        }
                    }

                    Divider()

                    Section {
                        Button(role: .destructive, action: {
                            // Code
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                        .disabled(true)

                        Button(action: {
                            // Code
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        .disabled(true)
                    }

                    Divider()

                    Button(action: {
                        // Code
                    }) {
                        Label("Add", systemImage: "plus.app")
                    }
                    .disabled(true)
                }, label: {
                    Text("Options")
                })
                .menuStyle(.automatic)
                .fixedSize()
            }
            .padding()
            .background()

            Divider()

            if filteredPoints.isEmpty {
                ContentUnavailableView.search
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background()
            } else {
                if isCompact {
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
                } else {
                    TableView(
                        grammarPoints: filteredPoints,
                        selectedGrammarID: $selectedGrammarID,
                        showingInspector: $showingInspector,
                        isCompact: isCompact
                    )
                    .toolbar {
                        ToolbarItem {
                            Button {
                                showingInspector.toggle()
                            } label: {
                                Label("More Info", systemImage: "sidebar.trailing")
                            }
                        }
                    }
                    .inspector(isPresented: $showingInspector) {
                        if let thisGrammarPoint = selectedGrammarPoint {
                            InspectorView(
                                grammarPoint: thisGrammarPoint,
                                isPresented: $showingInspector,
                                isCompact: isCompact
                            )
                        } else {
                            LegendView(isCompact: isCompact, isPresented: $showingInspector)
                        }
                    }
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
