//
//  SaveJournalAPI.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import Foundation

@MainActor
func submitJournalEntry(
    title: String,
    content: String,
    isPrivate: Bool
) async -> Result<String, Error> {
    let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
    let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard !trimmedTitle.isEmpty, !trimmedContent.isEmpty else {
        return .failure(
            NSError(domain: "", code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Please fill out all fields."])
        )
    }

    let journalEntry = JournalEntry(title: trimmedTitle, content: trimmedContent, isPrivate: isPrivate)
    
    guard let url = URL(string: "http://192.168.11.5:8000/api/journal") else {
        return .failure(URLError(.badURL))
    }

    do {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(journalEntry)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        if let id = try? JSONDecoder().decode(Int.self, from: data) {
            return .success("Journal saved (ID: \(id))")
        }
        return .failure(
            NSError(domain: "", code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Unknown error, journal not saved."])
        )
        
    } catch {
        return .failure(error)
    }
}
