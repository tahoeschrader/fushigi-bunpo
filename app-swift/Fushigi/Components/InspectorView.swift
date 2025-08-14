//
//  InspectorView.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/08.
//

import SwiftUI

struct InspectorView: View {
    let grammarPoint: GrammarPointModel
    @Binding var isPresented: Bool
    @Binding var selectedGrammarID: Int?
    let isCompact: Bool

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

#Preview {
    @Previewable @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    PreviewHelper.withGrammarStore { store in
        InspectorView(
            grammarPoint: store.grammarItems.last!,
            isPresented: .constant(true),
            selectedGrammarID: .constant(store.grammarItems.first!.id),
            isCompact: isCompact,
        )
    }
}
