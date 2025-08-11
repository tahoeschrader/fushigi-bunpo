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
    let created_at: Date
    let user_id: Int
    let content: String
    let `private`: Bool
    // let grammarPoints: [String]
    // let aiFeedback: String
}
