//
//  MainMenuController.swift
//  MainMenuController
//
//  Created by David Stephens on 17/09/2021.
//

import Foundation
import AppKit

enum MenuTag: Int {
    case about
    case services
    case preferences
}

class MainMenuController: NSObject {
    static let appMenuIdentifier = NSUserInterfaceItemIdentifier("AppMenu")
    

}

extension MainMenuController: NSMenuDelegate {
    private var expectedItems: [MenuItem?] {
        [nil, MenuItem.separator, MenuItem.prefs, nil, MenuItem.separator, nil, nil]
    }
    
    func numberOfItems(in menu: NSMenu) -> Int {
        return 7
    }
    
    func menu(_ menu: NSMenu, update item: NSMenuItem, at index: Int, shouldCancel: Bool) -> Bool {
        if menu.identifier == Self.appMenuIdentifier {
            guard let expectedItem = expectedItems[index] else {
                return true
            }
            guard !item.isSeparatorItem,
                  !expectedItem.isSeparator else {
                return true
            }
            
            if item.tag == expectedItem.tag?.rawValue {
                expectedItem.update(menuItem: item)
            } else {
                let newMenuItem = NSMenuItem()
                expectedItem.update(menuItem: newMenuItem)
                menu.insertItem(newMenuItem, at: index)
            }
            return true
        } else {
            return false
        }
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        print("opened")
    }
}
