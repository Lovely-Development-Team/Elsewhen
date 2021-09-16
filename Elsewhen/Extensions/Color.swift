//
//  Color.swift
//  Color
//
//  Created by David on 16/09/2021.
//

import Foundation
import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif

extension Color {
    #if os(iOS)
    static let secondarySystemBackground: Color = Color(UIColor.secondarySystemBackground)
    #elseif os(macOS)
    static let secondarySystemBackground: Color = Color(NSColor.controlBackgroundColor)
    #endif
}
