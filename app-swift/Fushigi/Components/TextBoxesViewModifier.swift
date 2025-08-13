//
//  TextBoxesViewModifier.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/10.
//

import SwiftUI

struct FocusBorder: ViewModifier {
    var isFocused: FocusState<Bool>.Binding // @Binding var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isFocused.wrappedValue ? Color.accentColor.opacity(0.5) : Color.gray.opacity(0.5),
                        lineWidth: 3,
                    ), // isFocused ?
            )
    }
}

extension View {
    func focusBorder(_ isFocused: FocusState<Bool>.Binding) -> some View { // Binding<Bool>
        modifier(FocusBorder(isFocused: isFocused))
    }
}
