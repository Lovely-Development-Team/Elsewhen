//
//  UserDefaults.swift
//  UserDefaults
//
//  Created by David Stephens on 17/09/2021.
//

import Foundation

extension UserDefaults {
    static let showMenuBarWidgetKey = "showMenuBarWidget"
    static let shouldTerminateAfterLastWindowClosedKey = "shouldTerminateAfterLastWindowClosed"
    
    @objc var showMenuBarWidget: Bool {
        get {
            bool(forKey: Self.showMenuBarWidgetKey)
        }
        set {
            set(newValue, forKey: Self.showMenuBarWidgetKey)
        }
    }
    
    var shouldTerminateAfterLastWindowClosed: Bool {
        get {
            bool(forKey: Self.shouldTerminateAfterLastWindowClosedKey)
        }
        set {
            set(newValue, forKey: Self.shouldTerminateAfterLastWindowClosedKey)
        }
    }
}
