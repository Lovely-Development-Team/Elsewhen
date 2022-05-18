//
//  PasteboardHelpers.swift
//  PasteboardHelpers
//
//  Created by David on 16/09/2021.
//


import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif
import UniformTypeIdentifiers

enum EWPasteboard {
    #if os(iOS)
    static func set(_ string: String, forType type: UTType) {
        UIPasteboard.general.setValue(string,
                                      forPasteboardType: type.identifier)
    }
    static func get() -> String? {
        return UIPasteboard.general.string
    }
    #elseif os(macOS)
    static func set(_ string: String, forType type: UTType) {
        NSPasteboard.general.clearContents()
        let didPaste = NSPasteboard.general.setString(string, forType: .init(type.identifier))
        assert(didPaste, "Paste should have been successflu")
    }
    #endif
}
