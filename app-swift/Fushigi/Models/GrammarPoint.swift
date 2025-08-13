//
//  GrammarPoint.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import Foundation

struct GrammarPoint: Identifiable, Decodable, Hashable {
    let id: Int
    let level: String
    let usage: String
    let meaning: String
    let tags: [String]
}
