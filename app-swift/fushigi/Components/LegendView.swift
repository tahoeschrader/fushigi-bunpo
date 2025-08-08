//
//  LegendView.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/08.
//

import SwiftUI

struct LegendView: View {
    let isCompact: Bool
    @Binding var isPresented: Bool
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

            ContentUnavailableView {
                Label("No Ideas", systemImage: "lightbulb")
            } description: {
                Text("Awaiting amazing ideas from the developer.")
            }
        }
        .padding()
    }
}
