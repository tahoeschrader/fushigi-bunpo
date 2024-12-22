//
//  AllGrammarView.swift
//  Fushigi
//
//  Created by Tahoe Schrader on R 6/11/20.
//

import SwiftUI
import SwiftData

struct AllGrammarView: View {
    @Query(sort: \Grammar.gid) var grammarPoints: [Grammar]
    @Query(sort: \Topic.name) var topics: [Topic]
    @Query(sort: \Style.name) var styles: [Style]
    
    var body: some View {
        List {
            Section(header: Text("Grammar (\(grammarPoints.count))")) {
                ForEach(grammarPoints) { grammarPoint in
                    Text(grammarPoint.name)
                }
            }

            Section(header: Text("Topics")) {
                ForEach(topics) { topic in
                    Text(topic.name)
                }
            }

            Section(header: Text("Styles")) {
                ForEach(styles) { style in
                    Text(style.name)
                }
            }
        }
    }
}

#Preview {
    AllGrammarView()
        .modelContainer(try! createModelContainer())  // Use the model container with Task handling
}
