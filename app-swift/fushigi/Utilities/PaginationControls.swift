//
//  PaginationControls.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/04.
//

import SwiftUI

struct PaginationControls: View {
    let currentPage: Int
    let maxPage: Int
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack {
            Button("Previous") {
                onPrevious()
            }
            .disabled(currentPage == 0)

            Text("Page \(currentPage + 1) of \(maxPage)")
                .font(.caption)
                .padding(.horizontal)

            Button("Next") {
                onNext()
            }
            .disabled(currentPage >= maxPage - 1)
        }
        .padding(.vertical, 8)
    }
}
