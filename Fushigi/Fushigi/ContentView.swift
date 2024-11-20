//
//  ContentView.swift
//  Fushigi
//
//  Created by Tahoe Schrader on R 6/11/20.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink("All", destination: AllGrammarView())
                NavigationLink("Random", destination: RandomGrammarView())
                NavigationLink("Journal", destination: JournalView())
                NavigationLink("History", destination: JournalHistoryView())
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)

#endif

            }
        } detail: {
            Text("Select a view in the sidebar...")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(try! createModelContainer())
}
