//
//  StatusBarMenuDelegate.swift
//  StatusBarMenuDelegate
//
//  Created by David Stephens on 17/09/2021.
//

import Cocoa

struct MenuItemContents {
    let sections: [MenuItemSection]
    private let allItems: [MenuItem]
    
    init(sections: [MenuItemSection]) {
        self.sections = sections
        var initialAllItems: [MenuItem] = []
        for section in sections {
            initialAllItems.append(contentsOf: section.items)
            initialAllItems.append(MenuItem(isSeparator: true))
        }
        self.allItems = initialAllItems
    }
}

extension MenuItemContents: Collection {
    typealias Index = Int
    typealias Element = MenuItem
    var startIndex: Index { return allItems.startIndex }
    var endIndex: Index { return allItems.endIndex }
    subscript(index: Index) -> Iterator.Element {
        get {
            return allItems[index]
        }
    }
    // Method that returns the next index when iterating
       func index(after i: Index) -> Index {
           return allItems.index(after: i)
       }
}

struct MenuItemSection {
    let items: [MenuItem]
    let count: Int
    init(items: [MenuItem]) {
        self.items = items
        self.count = items.count
    }
}

extension MenuItem {
    static let open = MenuItem(title: String.localizedStringWithFormat(NSLocalizedString("OpenMI", tableName: "Mac", comment: "Open app"), Bundle.displayName), target: WindowManager.shared, action: #selector(WindowManager.openMain))
    static let quit = MenuItem(title: String.localizedStringWithFormat(NSLocalizedString("QuitMI", tableName: "Mac", comment: "quit"), Bundle.displayName), target: NSApp, action: #selector(NSApp.terminate(_:)))
}

class StatusBarMenuDelegate: NSObject, NSMenuDelegate {
    static let shared = StatusBarMenuDelegate()
    var menuItems: MenuItemContents = MenuItemContents(sections: [MenuItemSection(items:[MenuItem.open]), MenuItemSection(items:[MenuItem.prefs]), MenuItemSection(items: [MenuItem.quit])])
    let menu = NSMenu()
    
    public override init() {
        super.init()
        menu.delegate = self
    }
    
    func popupAtMouseLocation() {
        menu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
    }
    
    func numberOfItems(in menu: NSMenu) -> Int {
        return menuItems.count
    }
    
    func menu(_ menu: NSMenu, update item: NSMenuItem, at index: Int, shouldCancel: Bool) -> Bool {
        guard !shouldCancel else {
            return false
        }
        let expectedItem = menuItems[index]
        if expectedItem.isSeparator {
            if item.isSeparatorItem {
                return true
            } else {
                menu.removeItem(at: index)
                menu.insertItem(NSMenuItem.separator(), at: index)
                return true
            }
        }
        expectedItem.update(menuItem: item)
        return true
    }
    
    
    
    func menuDidClose(_ menu: NSMenu) {
        StatusItemHandler.shared.statusItem?.button?.state = .off
    }
}
