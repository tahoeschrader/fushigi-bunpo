//
//  JournalView.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import SwiftUI

struct JournalView: View {
    @State private var title = ""
    @State private var content = ""
    @State private var isPrivate = false
    @State private var resultMessage: String?
    @State private var isSaving = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading) {
                Text("Title")
                    .font(.headline)
                TextField("Enter title", text: $title)
                    .textFieldStyle(.roundedBorder)
            }
            
            VStack(alignment: .leading) {
                Text("Content")
                    .font(.headline)
                TextEditor(text: $content)
                    .font(.custom("HelveticaNeue", size: 18))
                    .frame(height: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5))
                    )
            }
            
            Toggle("Private", isOn: $isPrivate)
            
            Button(action: {
                Task {
                    await submitJournal()
                }
            }) {
                if isSaving {
                    ProgressView()
                } else {
                    Text("Save")
                        .bold()
                }
            }
            .disabled(isSaving)
            .buttonStyle(.borderedProminent)
            
            if let msg = resultMessage {
                Text(msg)
                    .foregroundColor(msg.starts(with: "Error") ? .red : .green)
                    .padding(.top, 10)
            }
            
            Spacer()
        }
        .padding()
    }

    private func submitJournal() async {
        isSaving = true
        resultMessage = nil
        let result = await submitJournalEntry(title: title, content: content, isPrivate: isPrivate)
        switch result {
        case .success(let message):
            resultMessage = message
            title = ""
            content = ""
            isPrivate = false
        case .failure(let error):
            resultMessage = "Error: \(error.localizedDescription)"
        }
        isSaving = false
    }
}

#Preview {
    JournalView()
}
