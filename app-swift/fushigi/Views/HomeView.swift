//
//  HomeView.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/01.
//

import SwiftUI

struct HomeView: View {
    @State private var sortOrder = [KeyPathComparator(\TableData.givenName)]
    @State private var data = [
        TableData(givenName: "Juan", familyName: "Chavez", emailAddress: "juanchavez@icloud.com"),
        TableData(givenName: "Mei", familyName: "Chen", emailAddress: "meichen@icloud.com"),
        TableData(givenName: "Tom", familyName: "Clark", emailAddress: "tomclark@icloud.com"),
        TableData(givenName: "Gita", familyName: "Kumar", emailAddress: "gitakumar@icloud.com")
    ]
    @State private var selectedPerson: TableData.ID?
    @State private var showingInspector: Bool = false

    var selectedPersonData: TableData? {
        data.first(where: { $0.id == selectedPerson })
    }

    var body: some View {
        #if os(macOS)
        TableView(
            data: $data,
            selectedPerson: $selectedPerson,
            sortOrder: $sortOrder,
            showingInspector: $showingInspector
        )
        .toolbar {
            ToolbarItem {
                Button {
                    showingInspector.toggle()
                } label: {
                    Label("More Info", systemImage: "sidebar.trailing")
                }
            }
        }
        .inspector(isPresented: $showingInspector) {
            if let person = selectedPersonData {
                InspectorView(person: person, isPresented: $showingInspector)
            } else {
                LegendView()
            }
        }
        #else
        // Add a button for the legend view here
        TableView(
            data: $data,
            selectedPerson: $selectedPerson,
            sortOrder: $sortOrder,
            showingInspector: $showingInspector
        )
        .inspector(isPresented: $showingInspector) {
            if let person = selectedPersonData {
                InspectorView(person: person, isPresented: $showingInspector)
            }
        }
        #endif
    }
}

struct TableView: View {
    @Binding var data: [TableData]
    @Binding var selectedPerson: TableData.ID?
    @Binding var sortOrder: [KeyPathComparator<TableData>]
    @Binding var showingInspector: Bool

    var body: some View {
        Table(data, selection: $selectedPerson, sortOrder: $sortOrder) {
            TableColumn("Given Name", value: \.givenName)
            TableColumn("Family Name", value: \.familyName)
            TableColumn("E-Mail Address", value: \.emailAddress)
        }
        .onChange(of: sortOrder) { _, newValue in
            data.sort(using: newValue)
        }
        .onChange(of: selectedPerson) { _, newSelection in
            showingInspector = newSelection != nil
        }
    }
}

struct TableData: Identifiable {
    let givenName: String
    let familyName: String
    let emailAddress: String
    let id = UUID()

    var fullName: String { givenName + " " + familyName }
}

import SwiftUI

struct InspectorView: View {
    let person: TableData
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            #if os(iOS)
            HStack {
                Spacer()
                Button("Done") {
                    isPresented = false
                }
            }
            .padding(.horizontal)
            #endif
            
            VStack(alignment: .leading) {
                Text("Full Name: \(person.fullName)")
                Text("Email: \(person.emailAddress)")
                Divider()
                Text("Internal Notes: ...")
            }
            .padding()
            Spacer()
        }
        .padding()
        #if os(iOS)
        .presentationDetents([.fraction(0.5), .large])
        .transition(.move(edge: .bottom))
        #endif
    }
}

struct LegendView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Legend", systemImage: "sidebar.trailing")
                .labelStyle(.titleOnly)
                .font(.title2)
                .bold()

            Text("Select a person in the table to see detailed info here.")
                .font(.body)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Label("Name", systemImage: "person")
                Label("Age", systemImage: "calendar")
                Label("Email", systemImage: "envelope")
                Label("Status", systemImage: "circle.fill")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
    }
}


#Preview {
    HomeView()
}
