//
//  GrammarPoint.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import Foundation
import SwiftData

// MARK: - Remote Postgres model

struct GrammarPoint: Identifiable, Decodable, Hashable, Sendable {
    let id: Int
    let level: String
    let usage: String
    let meaning: String
    let tags: [String]
}

// MARK: - Local/iCloud model

@Model
final class GrammarPointModel {
    @Attribute(.unique) var id: Int
    var level: String
    var usage: String
    var meaning: String
    var tags: [String]

    init(id: Int, level: String, usage: String, meaning: String, tags: [String] = []) {
        self.id = id
        self.level = level
        self.usage = usage
        self.meaning = meaning
        self.tags = tags
    }
}
