//
//  GrammarTable.swift
//  Fushigi
//
//  Created by Tahoe Schrader on 2025/08/20.
//

import SwiftUI

// MARK: Grammar Table

/// Responsive table component for displaying grammar points with platform-appropriate layouts.
///
/// This view automatically adapts between single-column compact layouts optimized for
/// mobile interaction and multi-column expanded layouts that take advantage of larger
/// screen real estate. It handles selection state, refresh operations, and provides
/// smooth transitions between different presentation modes.
struct GrammarTable: View {
    @Binding var selectedGrammarID: UUID?
    @Binding var showingInspector: Bool

    let grammarPoints: [GrammarPointModel]
    let isCompact: Bool
    let onRefresh: () async -> Void

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

// MARK: Compact Grammar Table

/// Optimized row layout for compact table presentations on mobile devices.
///
/// This component presents grammar point information in a vertically stacked
/// format that maximizes readability on narrow screens while maintaining
/// clear visual hierarchy and essential information accessibility.
struct CompactGrammarRow: View {
    let grammarPoint: GrammarPointModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Primary usage information with visual emphasis
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(grammarPoint.usage)
                        .font(.body)
                        .fontWeight(.medium)

                    Spacer()

                    Text(grammarPoint.context)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(.quaternary)
                        .clipShape(Capsule())
                }

                Text(grammarPoint.meaning)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.quaternary.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(.quaternary, lineWidth: 1),
            )

            // Tag information with color coding
            if !grammarPoint.tags.isEmpty {
                coloredTagsText(tags: grammarPoint.tags)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}

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
