//
//  FushigiApp.swift
//  Fushigi
//
//  Created by Tahoe Schrader on R 6/11/20.
//

import SwiftUI
import SwiftData

@main
struct FushigiApp: App {
    var sharedModelContainer: ModelContainer = {
        do {
            return try createModelContainer()
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

@MainActor
func createModelContainer() throws -> ModelContainer {
    let schema = Schema([Item.self, Grammar.self, Topic.self, Style.self])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])

    guard let url = Bundle.main.url(forResource: "data", withExtension: "json") else {
        fatalError("JSON file not found")
    }

    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let rootData = try decoder.decode(RootData.self, from: data)
        
        print("Loaded data from JSON: \(rootData.grammar.count) grammar items, \(rootData.topics.count) topics, \(rootData.styles.count) styles.")

        try insertDataIntoModelContainer(modelContainer: modelContainer, rootData: rootData)
        return modelContainer
    } catch {
        print("Error decoding JSON: \(error)")
        fatalError("Failed to load and parse JSON")
    }
}

@MainActor
func insertDataIntoModelContainer(modelContainer: ModelContainer, rootData: RootData) throws {
    // Check if data has already been inserted
    if UserDefaults.standard.bool(forKey: "hasInitializedData") {
        print("Data has already been initialized. Skipping insertion.")
        return
    }
    
    do {
        // First delete old data (how to make it stop duplicating???)
        let existingGrammar = try modelContainer.mainContext.fetch(FetchDescriptor<Grammar>())
        let existingTopics = try modelContainer.mainContext.fetch(FetchDescriptor<Topic>())
        let existingStyles = try modelContainer.mainContext.fetch(FetchDescriptor<Style>())

        for item in existingGrammar {
            modelContainer.mainContext.delete(item)
        }
        for item in existingTopics {
            modelContainer.mainContext.delete(item)
        }
        for item in existingStyles {
            modelContainer.mainContext.delete(item)
        }
        
        // Now, add the defaults that should be there in the first place
        for grammar in rootData.grammar {
            let grammarModel = Grammar(
                name: grammar.name,
                level: grammar.level,
                tags: grammar.tags,
                notes: grammar.notes,
                example: grammar.example,
                gid: grammar.gid
            )
            modelContainer.mainContext.insert(grammarModel)
        }

        for topic in rootData.topics {
            let topicModel = Topic(
                name: topic.name
            )
            modelContainer.mainContext.insert(topicModel)
        }

        for style in rootData.styles {
            let styleModel = Style(
                name: style.name
            )
            modelContainer.mainContext.insert(styleModel)
        }
        
        try modelContainer.mainContext.save()
        print("Data saved successfully.")
        UserDefaults.standard.set(true, forKey: "hasInitializedData")
    } catch {
        print("Error inserting data: \(error)")
        throw error
    }
}
