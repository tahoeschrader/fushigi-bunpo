//
//  SystemState.swift
//  Fushigi
//
//  Created by Tahoe Schrader on 2025/08/23.
//

import SwiftUI

// MARK: - Data Availability

/// Represents whether the app has usable data for the user
enum DataAvailability {
    /// Loading data...
    case loading

    /// Data ready
    case available

    /// No data available
    case empty

    /// User friendly description of data availability
    var description: String {
        switch self {
        case .loading:
            "Loading data..."
        case .available:
            "Data ready"
        case .empty:
            "No data available"
        }
    }
}

// MARK: - System Health

/// Represents the health of our data sources
enum SystemHealth {
    /// All systems operational
    case healthy

    /// Local SwiftData corruption/failure
    case swiftDataError

    /// Unable to establish connection to PostgreSQL database
    case postgresError

    /// Both local and remote data sources failed
    case bothFailed

    /// User friendly description of data availability
    var description: String {
        switch self {
        case .healthy:
            "All systems operational"
        case .swiftDataError:
            "Local SwiftData corruption/failure"
        case .postgresError:
            "Unable to establish connection to PostgreSQL database"
        case .bothFailed:
            "Both local and remote data sources failed"
        }
    }

    var hasError: Bool {
        self != .healthy
    }
}

// MARK: - System State

/// The main state that drives UI rendering decisions
enum SystemState {
    /// Currently loading locally from SwiftData and fetching remotely from PostgreSQL
    case loading

    /// Standard operation with full data set
    case normal

    /// No data available
    case emptyData

    /// Has data but storage systems are unhealthy
    case degradedOperation(String)

    /// No data and storage systems are unhealthy
    case criticalError(String)

    /// User friendly description of all operating modes
    var description: String {
        switch self {
        case .loading:
            "Currently loading locally from SwiftData and fetching remotely from PostgreSQL"
        case .normal:
            "Standard operation with full data set"
        case .emptyData:
            "No data available"
        case let .degradedOperation(errorMessage):
            "Operating with local data only: \(errorMessage)"
        case let .criticalError(errorMessage):
            "Critical error: \(errorMessage)"
        }
    }

    /// Returns the appropriate ContentUnavailableView for the current state
    @ViewBuilder
    func contentUnavailableView(fixAction: @escaping () async -> Void) -> some View {
        Group {
            switch self {
            case .normal:
                // Normal state doesn't need an error view
                EmptyView()

            case .loading:
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

            case .emptyData:
                ContentUnavailableView {
                    Label("No Data", systemImage: "tray")
                } description: {
                    Text(description)
                        .foregroundColor(.secondary)
                } actions: {
                    Button("Refresh") {
                        Task { await fixAction() }
                    }
                    .buttonStyle(.bordered)
                }

            case let .degradedOperation(error):
                ContentUnavailableView {
                    Label("Limited Functionality", systemImage: "exclamationmark.triangle.fill")
                } description: {
                    Text(error)
                        .foregroundColor(.orange)
                } actions: {
                    Button("Retry Sync") {
                        Task { await fixAction() }
                    }
                    .buttonStyle(.bordered)
                }

            case let .criticalError(error):
                ContentUnavailableView {
                    Label("Critical Error", systemImage: "xmark.octagon.fill")
                } description: {
                    Text(error)
                        .foregroundColor(.red)
                } actions: {
                    Button("Retry") {
                        Task { await fixAction() }
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Define Store Protocol

/// Protocol that any store with sync functionality can adopt
@MainActor
protocol SyncableStore: ObservableObject {
    associatedtype DataType

    var items: [DataType] { get }
    var dataAvailability: DataAvailability { get set }
    var systemHealth: SystemHealth { get set }
}

/// Define shared attributes of all stores with sync
extension SyncableStore {
    /// Computed priority state for UI rendering decisions
    var systemState: SystemState {
        switch (dataAvailability, systemHealth) {
        case (.loading, _):
            .loading
        case (.empty, .healthy):
            .emptyData
        case (.empty, .swiftDataError), (.empty, .postgresError), (.empty, .bothFailed):
            .criticalError(systemHealth.description)
        case (.available, .healthy):
            .normal
        case (.available, .swiftDataError), (.available, .postgresError), (.available, .bothFailed):
            .degradedOperation(systemHealth.description)
        }
    }

    /// Mark as loading
    func setLoading() {
        dataAvailability = .loading
    }

    /// Handle local load failure
    func handleLocalLoadFailure() {
        systemHealth = (systemHealth == .postgresError) ? .bothFailed : .swiftDataError
        dataAvailability = items.isEmpty ? .empty : .available
    }

    /// Handle remote sync failure
    func handleRemoteSyncFailure() {
        systemHealth = (systemHealth == .swiftDataError) ? .bothFailed : .postgresError
        dataAvailability = items.isEmpty ? .empty : .available
    }

    /// Handle successful sync
    func handleSyncSuccess() {
        // Keep systemHealth if SwiftData previously failed, otherwise mark healthy
        if systemHealth != .swiftDataError {
            systemHealth = .healthy
        }
        dataAvailability = items.isEmpty ? .empty : .available
    }
}

// MARK: - State View Wrapper

/// Generic view for system state problems to simplify downstream logic
struct SystemStateView<Content: View>: View {
    let systemState: SystemState
    let onRefresh: () async -> Void
    let onEmptyData: (() -> Void)?
    let content: () -> Content

    init(
        systemState: SystemState,
        onRefresh: @escaping () async -> Void,
        onEmptyData: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content,
    ) {
        self.systemState = systemState
        self.onRefresh = onRefresh
        self.onEmptyData = onEmptyData
        self.content = content
    }

    var body: some View {
        switch systemState {
        case .normal:
            content()

        case let .degradedOperation(error):
            VStack(spacing: UIConstants.Spacing.tightRow) {
                WarningBanner(error: error, onRetry: onRefresh)
                content()
            }

        case .loading, .emptyData, .criticalError:
            systemState.contentUnavailableView {
                if case .emptyData = systemState {
                    onEmptyData?()
                }
                await onRefresh()
            }
        }
    }
}

// MARK: - Reusable Warning Banner

struct WarningBanner: View {
    let error: String
    let onRetry: () async -> Void

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text("Sync issues detected - showing local data only")
                .font(.caption)
                .foregroundColor(.orange)
            Spacer()
            Button("Retry") {
                Task { await onRetry() }
            }
            .font(.caption)
            .buttonStyle(.bordered)
        }
        .padding(.horizontal, UIConstants.Padding.capsuleWidth)
        .padding(.vertical, UIConstants.Padding.capsuleWidth)
        .background(Color.orange.opacity(0.1))
    }
}
