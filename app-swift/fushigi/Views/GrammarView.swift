//
//  GrammarView.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import SwiftUI

struct GrammarView: View {
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
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: searchText) {
                            // nothing right now
                        }
                }
                Button("Deselect"){
                    selectedGrammarID = nil
                }
            }
            .padding()
            .background()
            
            Divider()
            
            if filteredPoints.isEmpty {
                ContentUnavailableView.search
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background()
            } else {
#if os(macOS)
                TableView(
                    grammarPoints: filteredPoints,
                    selectedGrammarID: $selectedGrammarID,
                    showingInspector: $showingInspector
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
                        InspectorView(grammarPoint: thisGrammarPoint, isPresented: $showingInspector)
                    } else {
                        LegendView()
                    }
                }
#else
                TableView(
                    grammarPoints: filteredPoints,
                    selectedGrammarID: $selectedGrammarID,
                    showingInspector: $showingInspector
                )
                .inspector(isPresented: $showingInspector) {
                    if let thisGrammarPoint = selectedGrammarPoint {
                        InspectorView(grammarPoint: thisGrammarPoint, isPresented: $showingInspector)
                    }
                }
#endif
            }
        }
        .task {
            let result = await fetchGrammarPoints()
            switch result {
            case .success(let points):
                grammarPoints = points
                errorMessage = nil
            case .failure(let error):
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

struct TableView: View {
    let grammarPoints: [GrammarPoint]
    @Binding var selectedGrammarID: GrammarPoint.ID?
    @Binding var showingInspector: Bool
    
    var body: some View {
        Table(grammarPoints, selection: $selectedGrammarID) {
#if os(iOS)
            TableColumn("場合"){ point in
                VStack(alignment: .leading, spacing: 4) {
                    VStack(alignment: .leading, spacing: 4){
                        Text(point.usage)
                            .font(.body)
                        Text(point.meaning)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                        .padding(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.primary.opacity(0.4), lineWidth: 1)
                        )
                    coloredTagsText(tags: point.tags)
                        .font(.caption)

                }
                .padding(.vertical, 2)
            }
#else
#endif
            TableColumn("場合") { point in
                Text(point.level)
            }
            TableColumn("使い方") { point in
                VStack(alignment: .leading) {
                    Text(point.usage)
                    Text(point.meaning)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .lineLimit(nil)
            }
            TableColumn("タッグ") { point in
                coloredTagsText(tags: point.tags)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .onChange(of: selectedGrammarID) { _, newSelection in
            showingInspector = newSelection != nil
        }
    }
}

struct InspectorView: View {
    let grammarPoint: GrammarPoint
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
#if os(iOS)
            HStack {
                Spacer()
                Button("Done") {
                    isPresented = false
                }
            }
            .padding(.horizontal)
#endif

            VStack(alignment: .leading) {
                Text("Usage: \(grammarPoint.usage)")
                Text("Meaning: \(grammarPoint.meaning)")
                Divider()
                coloredTagsText(tags: grammarPoint.tags)
            }
            .padding()
            Spacer()
        }
        .padding()
#if os(iOS)
        .presentationDetents([.fraction(0.5), .large])
        .transition(.move(edge: .bottom))
#endif
    }
}

struct LegendView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Legend", systemImage: "sidebar.trailing")
                .labelStyle(.titleOnly)
                .font(.title2)
                .bold()

            Text("Select a person in the table to see detailed info here.")
                .font(.body)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Label("Name", systemImage: "person")
                Label("Age", systemImage: "calendar")
                Label("Email", systemImage: "envelope")
                Label("Status", systemImage: "circle.fill")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    GrammarView()
}
