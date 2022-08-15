//
//  RoundedRectangleButton.swift
//  Elsewhen
//
//  Created by David Stephens on 28/09/2021.
//

import SwiftUI

struct RoundedRectangleButton: ViewModifier {
    let colour: Color
    let horizontalPadding: CGFloat?
    let cornerRadius: CGFloat
    
    func contentView(_ content: Content) -> some View {
        content
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(colour)
        )
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
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
    func roundedRectangle(colour: Color = .accentColor, horizontalPadding: CGFloat? = nil, cornerRadius: CGFloat) -> ModifiedContent<Self, RoundedRectangleButton> {
        self.modifier(RoundedRectangleButton(colour: colour, horizontalPadding: horizontalPadding, cornerRadius: cornerRadius))
    }
    func roundedRectangle(colour: Color = .accentColor, horizontalPadding: CGFloat? = nil) -> ModifiedContent<Self, RoundedRectangleButton> {
        roundedRectangle(cornerRadius: 15)
    }
}
