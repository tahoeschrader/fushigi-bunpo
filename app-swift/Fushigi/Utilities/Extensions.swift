//
//  Extensions.swift
//  Fushigi
//
//  Created by Tahoe Schrader on 2025/08/20.
//

import Foundation
import SwiftUI

extension JSONDecoder {
    /// A JSONDecoder configured to decode ISO8601 dates with fractional seconds from timestamptz
    static var iso8601withFractionalSeconds: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            guard let date = formatter.date(from: dateStr) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid date string: \(dateStr)",
                )
            }
            return date
        }
        return decoder
    }
}

extension View {
    /// Applies `.tabBarMinimizeBehavior(.onScrollDown)` if available on iOS.
    @ViewBuilder
    func tabBarMinimizeOnScrollIfAvailable() -> some View {
        #if os(iOS)
            if #available(iOS 26.0, *) {
                self.tabBarMinimizeBehavior(.onScrollDown)
            } else {
                self
            }
        #else
            self
        #endif
    }
}

extension View {
    @ViewBuilder
    func searchableIf(_ condition: Bool, text: Binding<String>, prompt: String = "Search") -> some View {
        if condition {
            searchable(text: text, prompt: prompt)
        } else {
            self
        }
    }
}

/// Create a View extension that allows all Preview View objects to instantiate a fake data store to help with
/// debugging.
extension View {
    /// Makes sure the Preview component comes with a faked datastore for populating UI elements.
    ///
    /// Don't want this running on real data so it's desirable to create a datastore like this. We don't always
    /// need it though, so it's left as an optional extension.
    func withPreviewGrammarStore(mode: PreviewHelper = .normal) -> some View {
        PreviewHelper.withStore(mode: mode) { _ in
            self
        }
    }

    /// Wraps the view in NavigationStack for components requiring navigation context.
    ///
    /// Many SwiftUI components rely on navigation context for proper rendering of
    /// toolbars, titles, and navigation-dependent modifiers. This convenience method
    /// ensures preview components have the necessary navigation environment.
    func withPreviewNavigation() -> some View {
        NavigationStack {
            self
        }
    }
}
