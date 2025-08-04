//
//  ListJournalAPI.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/04.
//

import Foundation

@MainActor
func fetchJournalEntries() async -> Result<[JournalEntryInDB], Error> {
    guard let url = URL(string: "http://192.168.11.5:8000/api/journal") else {
        return .failure(URLError(.badURL))
    }
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        print(String(data: data, encoding: .utf8) ?? "Invalid UTF8")
        let entries = try JSONDecoder.iso8601withFractionalSeconds.decode([JournalEntryInDB].self, from: data)

        return .success(entries)
    } catch {
        return .failure(error)
    }

}
