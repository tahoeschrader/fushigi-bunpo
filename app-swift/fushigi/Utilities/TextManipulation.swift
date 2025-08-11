//
//  TextManipulation.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import SwiftUI

func coloredTagsText(tags: [String]) -> Text {
    var combinedText = Text("")

    for (index, tag) in tags.enumerated() {
        let coloredText = Text(tag)
            .font(.caption)
            .foregroundColor(index.isMultiple(of: 2) ? .primary : .secondary)

        combinedText = combinedText + coloredText

        if index < tags.count - 1 {
            combinedText = combinedText + Text("   ").font(.caption).foregroundColor(.primary)
        }
    }
    return combinedText
}
