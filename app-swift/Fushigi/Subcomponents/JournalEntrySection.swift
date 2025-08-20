//
//  JournalEntrySection.swift
//  Fushigi
//
//  Created by Tahoe Schrader on 2025/08/19.
//

import SwiftUI

/// Journal entry form with title, content, and save functionality.
///
/// This view allows users to write journal entries with automatic focus management,
/// privacy settings, and saves both the entry and any grammar tags to the database.
/// Future enhancements will include AI review and social features.
struct JournalEntrySection: View {
    /// Journal entry title
    @Binding var entryTitle: String

    /// Journal entry content
    @Binding var entryContent: String

    /// Text selection for grammar tagging
    @Binding var textSelection: TextSelection?

    /// Privacy flag for future social features
    @Binding var isPrivateEntry: Bool

    /// Status message for save operations
    @Binding var statusMessage: String?

    /// Saving state to disable UI during operations
    @Binding var isSaving: Bool

    /// Focus state for title field
    @FocusState private var isTitleFocused: Bool

    /// Focus state for content field
    @FocusState private var isContentFocused: Bool

    /// Focus state for content field
    @State private var showSaveConfirmation: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.sectionSpacing) {
            // Title input
            VStack(alignment: .leading, spacing: UIConstants.rowSpacing) {
                Text("Title").font(.headline)
                TextField("Enter title", text: $entryTitle)
                    .textFieldStyle(.plain)
                    .padding(UIConstants.rowSpacing)
                    .background(
                        Rectangle()
                            .stroke(isTitleFocused ? Color.accentColor : Color.primary,
                                    lineWidth: UIConstants.borderWidth),
                    )
                    .focused($isTitleFocused)
                    .onSubmit {
                        isContentFocused = true
                        isTitleFocused = false
                    }
                    .disabled(isSaving)
            }

            // Content input
            VStack(alignment: .leading, spacing: UIConstants.rowSpacing) {
                Text("Content").font(.headline)
                TextEditor(text: $entryContent, selection: $textSelection)
                    .font(.custom("HelveticaNeue", size: UIConstants.fontSize))
                    .frame(minHeight: UIConstants.contentMinHeight, maxHeight: .infinity)
                    .background(
                        Rectangle()
                            .stroke(isContentFocused ? Color.accentColor : Color.primary,
                                    lineWidth: UIConstants.borderWidth + 2),
                    )
                    .focused($isContentFocused)
                    .disabled(isSaving)
            }

            // Privacy toggle
            Toggle("Private Entry", isOn: $isPrivateEntry)
                .disabled(isSaving)

            // Save section
            HStack(alignment: .center) {
                Button {
                    showSaveConfirmation = true
                } label: {
                    if isSaving {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Text("Save").bold()
                    }
                }
                .confirmationDialog("Confirm Submission", isPresented: $showSaveConfirmation) {
                    Button("Confirm") {
                        Task {
                            await saveJournalEntry()
                        }
                    }
                } message: {
                    Text("Are you sure you're ready to submit this entry?")
                }
                .disabled(isSaving)
                .buttonStyle(.borderedProminent)
                .dialogIcon(Image(systemName: "questionmark.circle"))

                if let message = statusMessage {
                    Text(message)
                        .foregroundColor(message.hasPrefix("Error") ? .red : .green)
                }
            }
        }
    }

    /// Saves the journal entry to the database
    private func saveJournalEntry() async {
        guard !isSaving else { return }

        isSaving = true
        statusMessage = nil
        defer { isSaving = false }

        let result = await submitJournalEntry(
            title: entryTitle,
            content: entryContent,
            isPrivate: isPrivateEntry,
        )

        switch result {
        case let .success(message):
            statusMessage = message
            clearForm()
            print("Successfully posted journal entry.")
        case let .failure(error):
            statusMessage = "Error: \(error.localizedDescription)"
            print("Failed to post journal entry:", error)
        }
    }

    /// Clears the form after successful submission
    private func clearForm() {
        textSelection = nil // must clear textSelection first to be safe from index crash
        entryTitle = ""
        entryContent = ""
        isPrivateEntry = false
    }
}

// MARK: Previews

#Preview("Entry Form Only") {
    JournalEntrySection(
        entryTitle: .constant("Sample Title"),
        entryContent: .constant("Sample content with some text to show how the editor looks with content."),
        textSelection: .constant(nil),
        isPrivateEntry: .constant(false),
        statusMessage: .constant(nil),
        isSaving: .constant(false),
    )
    .padding()
}

#Preview("Loading State") {
    JournalEntrySection(
        entryTitle: .constant("My Daily Practice"),
        entryContent: .constant("今日は新しい文法を勉強しました。"),
        textSelection: .constant(nil),
        isPrivateEntry: .constant(true),
        statusMessage: .constant("Saving entry..."),
        isSaving: .constant(true),
    )
    .padding()
}
