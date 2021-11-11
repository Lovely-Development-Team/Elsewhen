//
//  UserDefaults.swift
//  UserDefaults
//
//  Created by David Stephens on 17/09/2021.
//

import Foundation

extension UserDefaults {
    enum Keys {
        static let showMenuBarWidgetKey = "showMenuBarWidget"
        static let shouldTerminateAfterLastWindowClosedKey = "shouldTerminateAfterLastWindowClosed"
    }
    
    @objc private var showMenuBarWidget: Bool {
        get {
            bool(forKey: Self.Keys.showMenuBarWidgetKey)
        }
        set {
            set(newValue, forKey: Self.Keys.showMenuBarWidgetKey)
        }
    }
    
    @objc static var showMenuBarWidget: Bool {
        get {
            Self.standard.bool(forKey: Self.Keys.showMenuBarWidgetKey)
        }
        set {
            Self.standard.set(newValue, forKey: Self.Keys.showMenuBarWidgetKey)
        }
    }
    static let showMenuBarWidgetPublisher = UserDefaults.standard.publisher(for: \.showMenuBarWidget)
    
    static var shouldTerminateAfterLastWindowClosed: Bool {
        get {
            Self.standard.bool(forKey: Self.Keys.shouldTerminateAfterLastWindowClosedKey)
        }
        set {
            Self.standard.set(newValue, forKey: Self.Keys.shouldTerminateAfterLastWindowClosedKey)
        }
    }
}
