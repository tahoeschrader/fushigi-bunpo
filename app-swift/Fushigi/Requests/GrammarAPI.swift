//
//  GrammarAPI.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import Foundation

/// Fetch all grammar points from FastAPI backend
@MainActor
func fetchGrammarPoints() async -> Result<[GrammarPointRemote], Error> {
    guard let url = URL(string: "http://192.168.11.5:8000/api/grammar") else {
        return .failure(URLError(.badURL))
    }

    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        let points = try JSONDecoder().decode([GrammarPointRemote].self, from: data)
        return .success(points)
    } catch {
        return .failure(error)
    }
}

/// Fetch random subset of grammar points from FastAPI backend
@MainActor
func fetchGrammarPointsRandom(filters _: [String] = []) async -> Result<[GrammarPointRemote], Error> {
    guard let url = URL(string: "http://192.168.11.5:8000/api/grammar?limit=true") else {
        return .failure(URLError(.badURL))
    }

    // For now, leave this commented out until I fix the SRS tables and routes
    // var request = URLRequest(url: url)
    // request.httpMethod = "POST"
    // request.httpBody = try? JSONEncoder().encode(filters)
    // request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    do {
        // let (data, _) = try await URLSession.shared.data(for: request)
        let (data, _) = try await URLSession.shared.data(from: url)
        let points = try JSONDecoder().decode([GrammarPointRemote].self, from: data)
        return .success(points)
    } catch {
        return .failure(error)
    }
}
