//
//  Constants.swift
//  Fushigi
//
//  Created by Tahoe Schrader on 2025/08/19.
//

import SwiftUI

// MARK: - UI Constants

/// Common UI spacing and sizing constants
enum UIConstants {
    enum Spacing {
        static let content: CGFloat = 20
        static let section: CGFloat = 16
        static let row: CGFloat = 8
        static let tightRow: CGFloat = 4
        static let `default`: CGFloat = 20
    }

    enum Sizing {
        static let contentMinHeight: CGFloat = 150
        static let defaultPadding: CGFloat = 10
        static let fontSize: CGFloat = 18
        static let icons: CGFloat = 60
        static let bigIcons: CGFloat = 120
        static let cornerRadius: CGSize = .init(width: 8, height: 8)
    }

    enum Border {
        static let width: CGFloat = 1
        static let focusedWidth: CGFloat = 2
    }

    enum Padding {
        static let capsuleWidth: CGFloat = 8
        static let capsuleHeight: CGFloat = 2
        static let largeIndent: CGFloat = 32
    }
}
