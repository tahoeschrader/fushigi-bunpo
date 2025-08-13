//
//  GameView.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/04.
//

import SwiftUI

struct GameView: View {
    var body: some View {
        ContentUnavailableView {
            Label("No Ideas", systemImage: "lightbulb")
        } description: {
            Text("Awaiting amazing ideas from the developer.")
        }
    }
}

#Preview {
    GameView()
}
