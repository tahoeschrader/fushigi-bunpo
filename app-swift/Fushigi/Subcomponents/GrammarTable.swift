//
//  GrammarTable.swift
//  Fushigi
//
//  Created by Tahoe Schrader on 2025/08/20.
//

import SwiftUI

// MARK: Grammar Table

/// Responsive table component for displaying grammar points with adaptive layouts
struct GrammarTable: View {
    /// Currently selected grammar point ID
    @Binding var selectedGrammarID: UUID?

    /// Controls inspector visibility
    @Binding var showingInspector: Bool

    /// Grammar points to display in table
    let grammarPoints: [GrammarPointLocal]

    /// Layout mode indicator for responsive design
    let isCompact: Bool

    /// Refresh callback for pull-to-refresh functionality
    let onRefresh: () async -> Void

    // MARK: - Main View

    var body: some View {
        Table(grammarPoints, selection: $selectedGrammarID) {
            if isCompact {
                TableColumn("Grammar Points") { point in
                    CompactGrammarRow(grammarPoint: point)
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
            withAnimation(.easeInOut(duration: 0.2)) {
                showingInspector = newSelection != nil
            }
        }
        .onChange(of: showingInspector) { _, newValue in
            if !newValue {
                selectedGrammarID = nil
            }
        }
        .refreshable {
            await onRefresh()
        }
    }
}

// MARK: - Compact Grammar Row

/// Optimized row layout for compact table presentations on mobile devices
struct CompactGrammarRow: View {
    /// Grammar point to display in compact format
    let grammarPoint: GrammarPointLocal

    // MARK: - Main View

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.Spacing.row) {
            VStack(alignment: .leading, spacing: 4) {
                Text(grammarPoint.usage)
                    .font(.body)
                    .fontWeight(.medium)
                Text(grammarPoint.meaning)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(UIConstants.Sizing.defaultPadding)
            .background(.quaternary.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 20))

            HStack {
                if !grammarPoint.tags.isEmpty {
                    coloredTagsText(tags: grammarPoint.tags)
                        .font(.caption)
                }

                Spacer()

                Text(grammarPoint.context)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(.quaternary)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, UIConstants.Sizing.defaultPadding)
        }
    }
}

// MARK: - Previews

#Preview {
    @Previewable @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var isCompact: Bool { horizontalSizeClass == .compact }

    PreviewHelper.withStore { store in
        GrammarTable(
            selectedGrammarID: .constant(nil),
            showingInspector: .constant(true),
            grammarPoints: store.getAllGrammarPoints(),
            isCompact: isCompact,
            onRefresh: {},
        )
    }
}
