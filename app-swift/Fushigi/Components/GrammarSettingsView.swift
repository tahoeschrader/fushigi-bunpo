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

    var onRefresh: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            #if os(iOS)
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
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { dismiss() }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Refresh") { onRefresh() }
                    }
                }
            #else
                VStack(alignment: .leading, spacing: 16) {
                    Picker("Source", selection: $selectedSource) {
                        ForEach(SourceMode.allCases) { source in
                            Text(source.description).tag(source)
                        }
                    }.labelsHidden()

                    Divider()

                    Text("Filters").font(.headline)

                    Picker("Context", selection: $selectedContext) {
                        ForEach(Context.allCases) { context in
                            Text(context.description).tag(context)
                        }
                    }.labelsHidden()

                    Picker("Level", selection: $selectedLevel) {
                        ForEach(Level.allCases) { level in
                            Text(level.description).tag(level)
                        }
                    }.labelsHidden()

                    Picker("Fun Mode", selection: $selectedFunMode) {
                        ForEach(FunMode.allCases) { mode in
                            Text(mode.description).tag(mode)
                        }
                    }.labelsHidden()

                    HStack {
                        Spacer()
                        Button("Refresh") { onRefresh() }
                        Button("Done") { dismiss() }
                    }
                }
                .padding()
            #endif
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
        onRefresh: {},
    )
}
