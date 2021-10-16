//
//  SharingHelpers.swift
//  Elsewhen
//
//  Created by David Stephens on 16/10/2021.
//

import Foundation
#if canImport(Cocoa)
import Cocoa
#endif
#if canImport(UIKit)
import UIKit
#endif

func postShowShareSheet(with items: [Any]) {
    NotificationCenter.default.post(name: .EWShouldOpenShareSheet, object: appDelegate(), userInfo: [ActivityItemsKey: items])
}

#if os(macOS)
func appDelegate() -> NSApplicationDelegate? {
    return NSApp.delegate
}
#else
func appDelegate() -> UIApplicationDelegate? {
    return UIApplication.shared.delegate
}
#endif

struct ShareSheetItem: Identifiable {
    let id = UUID()
    let items: [Any]
}
