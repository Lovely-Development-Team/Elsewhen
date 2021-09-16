//
//  InlineNavigationBarTitle.swift
//  InlineNavigationBarTitle
//
//  Created by David on 16/09/2021.
//

import SwiftUI

struct InlineNavigationBarTitle: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        content
            .navigationBarTitleDisplayMode(.inline)
        #else
        content
        #endif
    }
}

extension View {
    func inlineNavigationBarTitle() -> some View {
        self.modifier(InlineNavigationBarTitle())
    }
}
