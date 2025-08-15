//
//  TableView.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/08.
//

import SwiftUI

struct TableView: View {
    var grammarPoints: [GrammarPointModel]
    @Binding var selectedGrammarID: Int?
    @Binding var showingInspector: Bool
    let isCompact: Bool
    var onRefresh: () async -> Void

    var body: some View {
        Table(grammarPoints, selection: $selectedGrammarID) {
            if isCompact {
                TableColumn("場合") { point in
                    VStack(alignment: .leading, spacing: 4) {
                        VStack(alignment: .leading, spacing: 4) {
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
                                .stroke(Color.primary.opacity(0.4), lineWidth: 1),
                        )
                        coloredTagsText(tags: point.tags)
                            .font(.caption)
                    }
                    .padding(.vertical, 2)
                }
            } else {
                TableColumn("場合") { point in
                    Text(point.context)
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
        }
        .onChange(of: selectedGrammarID) { _, newSelection in
            showingInspector = newSelection != nil
        }
        .scrollDismissesKeyboard(.interactively)
        .refreshable {
            await onRefresh()
        }
    }
}

#Preview {
    @Previewable @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var isCompact: Bool { horizontalSizeClass == .compact }

    PreviewHelper.withGrammarStore { store in
        TableView(
            grammarPoints: store.getAllGrammarPoints(),
            selectedGrammarID: .constant(nil),
            showingInspector: .constant(true),
            isCompact: isCompact,
            onRefresh: {},
        )
    }
}
