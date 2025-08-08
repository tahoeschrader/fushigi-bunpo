//
//  InspectorView.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/08.
//

import SwiftUI

struct InspectorView: View {
    let grammarPoint: GrammarPoint
    @Binding var isPresented: Bool
    let isCompact: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isCompact {
                HStack {
                    Spacer()
                    Button("Done") {
                        isPresented = false
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
