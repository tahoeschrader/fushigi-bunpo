//
//  GrammarSettingsView.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/09.
//

import SwiftUI

// MARK: - Grammar Settings View

/// Comprehensive settings interface for configuring grammar point selection and filtering.
///
/// This view provides users with granular control over their practice experience,
/// allowing customization of politeness levels, usage contexts, regional variants,
/// and sourcing algorithms. Settings are managed internally and automatically
/// persisted, eliminating the need for external state coordination.
///
/// The interface uses semantic grouping and clear labeling to help users understand
/// how their choices affect the grammar points they'll encounter during practice.
struct GrammarSettingsView: View {
    @Binding var selectedLevel: Level
    @Binding var selectedContext: Context
    @Binding var selectedFunMode: FunMode
    @Binding var selectedSource: SourceMode

    var body: some View {
        Form {
            // Primary sourcing method configuration
            Section {
                Picker("Grammar Source", selection: $selectedSource) {
                    ForEach(SourceMode.allCases) { source in
                        Label(source.displayName, systemImage: source.icon)
                            .tag(source)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Source Method")
            } footer: {
                Text(sourceFooterText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Content filtering options
            Section("Content Filters") {
                Picker("Usage Context", selection: $selectedContext) {
                    ForEach(Context.allCases) { context in
                        Text(context.displayName).tag(context)
                    }
                }

                Picker("Politeness Level", selection: $selectedLevel) {
                    ForEach(Level.allCases) { level in
                        Text(level.displayName).tag(level)
                    }
                }

                Picker("Language Variants", selection: $selectedFunMode) {
                    ForEach(FunMode.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
            }
        }
        .formStyle(.grouped)
    }

    /// Dynamic footer text explaining the current source mode selection
    private var sourceFooterText: String {
        switch selectedSource {
        case .random:
            "Randomly selected grammar points for varied practice"
        case .srs:
            "Algorithmically chosen points based on your learning progress"
        }
    }
}

// MARK: Previews

#Preview("Settings View") {
    GrammarSettingsView(
        selectedLevel: .constant(.all),
        selectedContext: .constant(.all),
        selectedFunMode: .constant(.none),
        selectedSource: .constant(.random),
    )
    .withPreviewNavigation()
    .navigationTitle("Practice Settings")
}
