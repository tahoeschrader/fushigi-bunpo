//
//  Tags.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/09.
//

import SwiftUI

// MARK: - Enums

/// Politeness level filter options
enum Level: String, CaseIterable, Identifiable {
    case all = "All Levels"
    case casual = "Casual"
    case polite = "Polite"
    case keigo = "Keigo"
    case sonkeigo = "Sonkeigo"
    case kenjougo = "Kenjougo"

    var id: String { rawValue }

    /// User-friendly display name for the politeness level
    var displayName: String {
        switch self {
        case .all: "All Levels"
        case .casual: "Casual"
        case .polite: "Polite"
        case .keigo: "Keigo"
        case .sonkeigo: "Sonkeigo"
        case .kenjougo: "Kenjougo"
        }
    }
}

/// Usage context filter options
enum Context: String, CaseIterable, Identifiable {
    case all = "All Contexts"
    case spoken = "Spoken"
    case written = "Written"
    case business = "Business"

    var id: String { rawValue }

    /// User-friendly display name for the usage context
    var displayName: String {
        switch self {
        case .all: "All Contexts"
        case .written: "Written"
        case .spoken: "Spoken"
        case .business: "Business"
        }
    }
}

/// Language variant filter options
enum FunMode: String, CaseIterable, Identifiable {
    case none = "No Extras"
    case slang = "Slang"
    case kansai = "Kansai"

    var id: String { rawValue }

    /// User-friendly display name for the language variant
    var displayName: String {
        switch self {
        case .none: "Standard Japanese"
        case .slang: "Slang & Colloquial"
        case .kansai: "Kansai Dialect"
        }
    }
}

/// Grammar sourcing algorithm options
enum SourceMode: String, CaseIterable, Identifiable {
    case random = "Random"
    case srs = "SRS"

    var id: String { rawValue }

    /// User-friendly display name for the source mode
    var displayName: String {
        switch self {
        case .random: "Random"
        case .srs: "SRS"
        }
    }

    /// Icon representing the source mode concept
    var icon: String {
        switch self {
        case .random: "shuffle"
        case .srs: "brain.head.profile"
        }
    }
}

// MARK: - Helper Functions

/// Create colored text from array of tags
func coloredTagsText(tags: [String]) -> Text {
    var combinedText = Text("")

    for (index, tag) in tags.enumerated() {
        let coloredText = Text(tag)
            .font(.caption)
            .foregroundColor(index.isMultiple(of: 2) ? .primary : .secondary)

        // swiftlint:disable:next shorthand_operator
        combinedText = combinedText + coloredText

        if index < tags.count - 1 {
            // swiftlint:disable:next shorthand_operator
            combinedText = combinedText + Text("   ").font(.caption).foregroundColor(.primary)
        }
    }
    return combinedText
}
