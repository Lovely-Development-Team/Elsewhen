//
//  MainMenuController.swift
//  MainMenuController
//
//  Created by David Stephens on 17/09/2021.
//

import Foundation
import AppKit

class MainMenuController: NSObject {
    static let appMenuIdentifier = NSUserInterfaceItemIdentifier("AppMenu")
    
    static let expectedItems: [MenuItem?] = [nil, MenuItem.separator, MenuItem.prefs, nil, MenuItem.separator, nil, nil, nil, MenuItem.separator, nil]
}

extension MainMenuController: NSMenuDelegate {
    
    func numberOfItems(in menu: NSMenu) -> Int {
        return Self.expectedItems.count
    }
    
    func menu(_ menu: NSMenu, update item: NSMenuItem, at index: Int, shouldCancel: Bool) -> Bool {
        if menu.identifier == Self.appMenuIdentifier {
            guard let expectedItem = Self.expectedItems[index] else {
                return true
            }
            guard !item.isSeparatorItem,
                  !expectedItem.isSeparator else {
                return true
            }
            
            if item.tag == expectedItem.tag?.rawValue {
                // We've tagged this, so it's "ours" and we'll just update it
                expectedItem.update(menuItem: item)
            } else {
                // Put the item we expected above this one
                let endMenuItem = menu.item(at: menu.items.endIndex-1) ?? NSMenuItem()
                let menuItem = endMenuItem.title == "" && endMenuItem.isSeparatorItem == false ? endMenuItem : NSMenuItem()
                expectedItem.update(menuItem: menuItem)
                menu.removeItem(menuItem)
                menu.insertItem(menuItem, at: index)
            }
            return true
        } else {
            return false
        }
    }
}
