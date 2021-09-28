//
//  RoundedRectangleButton.swift
//  Elsewhen
//
//  Created by David Stephens on 28/09/2021.
//

import SwiftUI

struct RoundedRectangleButton: ViewModifier {
    let colour: Color
    
    func contentView(_ content: Content) -> some View {
        content
        .padding(.horizontal)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(colour)
        )
    }
    
    func body(content: Content) -> some View {
        #if os(macOS)
        contentView(content)
            .buttonStyle(PlainButtonStyle())
        #else
        contentView(content)
        #endif
    }
}

extension Button {
    func roundedRectangle(colour: Color = .accentColor) -> ModifiedContent<Self, RoundedRectangleButton> {
        self.modifier(RoundedRectangleButton(colour: colour))
    }
}
