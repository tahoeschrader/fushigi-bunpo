//
//  GrammarAPI.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import Foundation

/// Needed for serialization from JSON -- keep this internal to the store / don't call directly from views
@MainActor
func fetchGrammarPoints() async -> Result<[GrammarPoint], Error> {
    guard let url = URL(string: "http://192.168.11.5:8000/api/grammar") else {
        return .failure(URLError(.badURL))
    }

    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        let points = try JSONDecoder().decode([GrammarPoint].self, from: data)
        return .success(points)
    } catch {
        return .failure(error)
    }
}

/// Needed for local storage of API data to share across devices/app persistence
@MainActor
func fetchGrammarPointsLimited() async -> Result<[GrammarPoint], Error> {
    guard let url = URL(string: "http://192.168.11.5:8000/api/grammar?limit=true") else {
        return .failure(URLError(.badURL))
    }

    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        let points = try JSONDecoder().decode([GrammarPoint].self, from: data)
        return .success(points)
    } catch {
        return .failure(error)
    }
}
