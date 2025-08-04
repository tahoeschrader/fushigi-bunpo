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
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isCompact: Bool { horizontalSizeClass == .compact }
    #else
    private let isCompact = false
    #endif

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
                        .onChange(of: searchText){
                            currentPage = 0
                        }
                }
            }
            .padding()
            .background()
            
            // Table (macOS, iPad landscape, etc.)
            if !isCompact {
                Table(paginatedPoints) {
                    TableColumn("場合", value: \.level)
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
            } else {
                // List (iPhone, compact size)
                List(paginatedPoints) { point in
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
            }
            // Page controls
            PaginationControls(
                currentPage: currentPage,
                maxPage: maxPage,
                onPrevious: { if currentPage > 0 { currentPage -= 1 } },
                onNext: { if currentPage < maxPage - 1 { currentPage += 1 } }
            )
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .background()
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
    
    var maxPage: Int {
        let count = filteredPoints.count
        return (count + pageSize - 1) / pageSize // ceil division
    }

    var paginatedPoints: [GrammarPoint] {
        let start = currentPage * pageSize
        let end = min(start + pageSize, filteredPoints.count)
        guard start < end else { return [] }
        return Array(filteredPoints[start..<end])
    }
}

#Preview {
    GrammarView()
}
