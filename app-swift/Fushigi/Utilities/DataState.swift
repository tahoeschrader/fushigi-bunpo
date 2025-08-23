//
//  DataState.swift
//  Fushigi
//
//  Created by Tahoe Schrader on 2025/08/23.
//

import SwiftUI

/// Current state of database health or error mode
enum DataState {
    case normal
    case emptyData
    case syncError
    case networkLoading
    case postgresConnectionError

    /// Description of each state
    var description: String {
        switch self {
        case .normal:
            "Standard operation with full sample data set"
        case .emptyData:
            "No data available, no matches against filter, first-time user experience, or bug wipe"
        case .syncError:
            "General synchronization failure with remote or local services"
        case .networkLoading:
            "Currently loading local data and fetching from PostgreSQL"
        case .postgresConnectionError:
            "Unable to establish connection to PostgreSQL database"
        }
    }

    /// Returns the appropriate ContentUnavailableView for the current state
    @ViewBuilder
    func contentUnavailableView(fixAction: @escaping () async -> Void) -> some View {
        Group {
            switch self {
            case .normal:
                EmptyView() // Normal state doesn't need an error view

            case .emptyData, .syncError, .postgresConnectionError:
                ContentUnavailableView {
                    Label("Grammar Points Unavailable", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(description)
                        .foregroundColor(.red)
                } actions: {
                    Button("Refresh") {
                        Task { await fixAction() }
                    }
                    .buttonStyle(.bordered)
                }

            case .networkLoading:
                ContentUnavailableView {
                    VStack(spacing: UIConstants.Spacing.section) {
                        ProgressView()
                            .scaleEffect(2.5)
                            .frame(height: UIConstants.Sizing.icons)
                        Text("Loading")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                } description: {
                    Text(description)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Extend to allow for matching on Error
extension DataState: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .normal, .networkLoading:
            nil // These aren't really errors
        case .emptyData, .syncError, .postgresConnectionError:
            description
        }
    }
}
