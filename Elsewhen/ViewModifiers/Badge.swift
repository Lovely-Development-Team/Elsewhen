//
//  Badge.swift
//  Elsewhen
//
//  Created by Ben Cardy on 20/01/2022.
//

import SwiftUI

@available(iOS 15, *)
struct Badge: ViewModifier {
    let text: String?
    func body(content: Content) -> some View {
        content
            .badge(Text(text ?? ""))
    }
}

extension View {
    @ViewBuilder
    func iconBadge(_ text: String? = nil) -> some View {
        if #available(iOS 15, *) {
            self
                .modifier(Badge(text: text))
        }
        else {
            self
        }
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
