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
    let id: UUID
    let context: String
    let usage: String
    let meaning: String
    let tags: [String]

    init(from model: GrammarPointModel) {
        id = model.id
        context = model.context
        usage = model.usage
        meaning = model.meaning
        tags = model.tags
    }
}

// MARK: - Local/iCloud model

@Model
final class GrammarPointModel {
    @Attribute(.unique) var id: UUID
    var context: String
    var usage: String
    var meaning: String
    var tags: [String]

    init(id: UUID, context: String, usage: String, meaning: String, tags: [String] = []) {
        self.id = id
        self.context = context
        self.usage = usage
        self.meaning = meaning
        self.tags = tags
    }
}
