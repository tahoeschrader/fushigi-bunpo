//
//  JournalEntry.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import Foundation

struct JournalEntry: Codable {
    let title: String
    let content: String
    let `private`: Bool
}

struct ResponseID: Decodable {
    let id: Int
}

struct JournalEntryInDB: Identifiable, Decodable {
    let id: Int
    let title: String
    let createdAt: Date
    let userId: Int
    let content: String
    let `private`: Bool
    // let grammarPoints: [String]
    // let aiFeedback: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case createdAt = "created_at"
        case userId = "user_id"
        case content
        case `private`
    }
}
