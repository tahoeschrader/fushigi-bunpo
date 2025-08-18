//
//  GrammarSettingsView.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/09.
//

import SwiftUI

struct GrammarSettingsView: View {
    @Binding var selectedLevel: Level
    @Binding var selectedContext: Context
    @Binding var selectedFunMode: FunMode
    @Binding var selectedSource: SourceMode

    var body: some View {
        Form {
            Section {
                Picker("Source", selection: $selectedSource) {
                    ForEach(SourceMode.allCases) { source in
                        Text(source.description).tag(source)
                    }
                }
            }

            Section("Filters") {
                Picker("Context", selection: $selectedContext) {
                    ForEach(Context.allCases) { context in
                        Text(context.description).tag(context)
                    }
                }
                Picker("Level", selection: $selectedLevel) {
                    ForEach(Level.allCases) { level in
                        Text(level.description).tag(level)
                    }
                }
                Picker("Fun Mode", selection: $selectedFunMode) {
                    ForEach(FunMode.allCases) { mode in
                        Text(mode.description).tag(mode)
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedLevel: Level = .all
    @Previewable @State var selectedContext: Context = .all
    @Previewable @State var selectedFunMode: FunMode = .none
    @Previewable @State var selectedSource: SourceMode = .random

    GrammarSettingsView(
        selectedLevel: $selectedLevel,
        selectedContext: $selectedContext,
        selectedFunMode: $selectedFunMode,
        selectedSource: $selectedSource,
    )
}
