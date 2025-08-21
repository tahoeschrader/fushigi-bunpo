//
//  DetailedGrammar.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/08.
//

import SwiftUI

// MARK: - DetailedGrammar

/// Detailed view displaying comprehensive grammar point information
struct DetailedGrammar: View {
    /// Grammar point to display
    let grammarPoint: GrammarPointLocal

    /// Controls view presentation state
    @Binding var isPresented: Bool

    /// Currently selected grammar point ID
    @Binding var selectedGrammarID: UUID?

    /// Layout mode indicator for responsive design
    let isCompact: Bool

    // MARK: - Main View

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isCompact {
                HStack {
                    Spacer()
                    Button("Done") {
                        isPresented = false
                        selectedGrammarID = nil
                    }
                }
                .padding(.horizontal)
            }

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
    }
}

// MARK: - Previews

#Preview {
    @Previewable @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    PreviewHelper.withStore { store in
        DetailedGrammar(
            grammarPoint: store.grammarItems.last!,
            isPresented: .constant(true),
            selectedGrammarID: .constant(store.grammarItems.first!.id),
            isCompact: isCompact,
        )
    }
}
