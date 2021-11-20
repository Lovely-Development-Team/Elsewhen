//
//  Selectable.swift
//  Elsewhen
//
//  Created by David on 21/10/2021.
//

import SwiftUI

struct Selectable: ViewModifier {
    func body(content: Content) -> some View {
        // We shouldn't need this compiler conditional, but release Xcode doesn't have the symbols for Monterey
        if #available(iOS 15, macOS 12, *) {
            content
                .textSelection(.enabled)
        } else {
            content
        }
    }
}

extension View {
    func selectable() -> some View {
        self.modifier(Selectable())
    }
}
