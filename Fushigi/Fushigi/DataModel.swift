//
//  DataModel.swift
//  Fushigi
//
//  Created by Tahoe Schrader on R 6/11/20.
//

import SwiftData
import Foundation

@Model
class Grammar: Identifiable {
    @Attribute var name: String
    @Attribute var level: String
    @Attribute var tags: Set<String>
    @Attribute var notes: String
    @Attribute var example: Set<String>
    @Attribute var gid: String
    
    init(name: String, level: String, tags: Set<String>, notes: String, example: Set<String>, gid: String) {
        self.name = name
        self.level = level
        self.tags = tags
        self.notes = notes
        self.example = example
        self.gid = gid
    }
}

@Model
class Topic: Identifiable {
    @Attribute var name: String
    
    init(name: String) {
        self.name = name
    }
}

@Model
class Style: Identifiable {
    @Attribute var name: String
    
    init(name: String) {
        self.name = name
    }
}

@Model
class Root {
    @Relationship var grammar: [Grammar]
    @Relationship var topics: [Topic]
    @Relationship var styles: [Style]
    
    init(grammar: [Grammar], topics: [Topic], styles: [Style]) {
        self.grammar = grammar
        self.topics = topics
        self.styles = styles
    }
}

struct GrammarData: Decodable {
    let name: String
    let level: String
    let tags: Set<String>
    let notes: String
    let example: Set<String>
    let gid: String
}

struct TopicData: Decodable {
    let name: String
}

struct StyleData: Decodable {
    let name: String
}

struct RootData: Decodable {
    let grammar: [GrammarData]
    let topics: [TopicData]
    let styles: [StyleData]
}
