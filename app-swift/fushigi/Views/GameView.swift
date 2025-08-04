//
//  GameView.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/04.
//

import SwiftUI

struct GameView: View {
    var body: some View {
        Text("Put some fun games here")
            .frame(maxWidth: .infinity, minHeight: 100, alignment: .center)
            .background(
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 100)
                    .cornerRadius(8)
            )
            .padding()
    }
}

#Preview {
    GameView()
}
