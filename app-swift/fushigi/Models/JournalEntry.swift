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
    let isPrivate: Bool
}
