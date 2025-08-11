//
//  Tags.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/09.
//

enum Level: String, CaseIterable, Identifiable {
    case all = "all levels"
    case casual
    case polite
    case keigo
    case sonkeigo
    case kenjougo

    var id: String { rawValue }
    var description: String { rawValue.capitalized }
}

enum Context: String, CaseIterable, Identifiable {
    case all = "all contexts"
    case spoken
    case written
    case business

    var id: String { rawValue }
    var description: String { rawValue.capitalized }
}

enum FunMode: String, CaseIterable, Identifiable {
    case none = "no extras"
    case slang
    case kansai

    var id: String { rawValue }
    var description: String { rawValue.capitalized }
}

enum SourceMode: String, CaseIterable, Identifiable {
    case random
    case srs = "SRS"

    var id: String { rawValue }
    var description: String { rawValue.capitalized }
}
