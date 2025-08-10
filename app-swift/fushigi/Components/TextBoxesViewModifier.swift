//
//  TextBoxesViewModifier.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/10.
//

import SwiftUI

struct FocusBorder: ViewModifier {
    @Binding var isFocused: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isFocused ? Color.accentColor.opacity(0.1) : Color.clear)
            )
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isFocused ? Color.accentColor.opacity(0.5) : Color.gray.opacity(0.5), lineWidth: 2)
            )
    }
}

extension View {
    func focusBorder(_ isFocused: Binding<Bool>) -> some View {
        self.modifier(FocusBorder(isFocused: isFocused))
    }
}
