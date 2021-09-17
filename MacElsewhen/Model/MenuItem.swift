//
//  MenuItem.swift
//  MenuItem
//
//  Created by David Stephens on 17/09/2021.
//

import Cocoa

struct MenuItem {
    private let title: String
    private let target: AnyObject?
    private let action: Selector?
    private let keyEquivalent: String
    let tag: MenuTag?
    let isSeparator: Bool
    
    init(title: String, target: AnyObject?, action: Selector?, keyEquivalent: String = "", tag: MenuTag? = nil) {
        self.title = title
        self.target = target
        self.action = action
        self.keyEquivalent = keyEquivalent
        self.tag = tag
        self.isSeparator = false
    }
    
    init(isSeparator: Bool) {
        self.title = ""
        self.target = nil
        self.action = nil
        self.keyEquivalent = ""
        self.tag = nil
        self.isSeparator = isSeparator
    }
    
    func update(menuItem item: NSMenuItem) {
        item.title = self.title
        item.target = self.target
        item.action = self.action
        item.keyEquivalent = self.keyEquivalent
        item.tag = self.tag?.rawValue ?? 0
    }
}

extension MenuItem {
    static let separator = MenuItem(isSeparator: true)
    static let prefs = MenuItem(title: NSLocalizedString("PreferencesMI", tableName: "Mac", comment: "preferences"), target: WindowManager.shared, action: #selector(WindowManager.openPreferences), keyEquivalent: ",", tag: .preferences)
}
