//
//  Badge.swift
//  Elsewhen
//
//  Created by Ben Cardy on 20/01/2022.
//

import SwiftUI

struct Badge: ViewModifier {
    let text: String?
    func body(content: Content) -> some View {
        if #available(iOS 15, *) {
            content
                .badge(Text(text ?? ""))
        } else {
            content
        }
    }
}

extension View {
    @ViewBuilder
    func iconBadge(_ text: String? = nil) -> some View {
        self.modifier(Badge(text: text))
    }
    @ViewBuilder
    func iconBadge(isPresented: Bool, text: String? = nil) -> some View {
        if isPresented {
            self.iconBadge(text)
        } else {
            self
        }
    }
}
