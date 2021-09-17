//
//  StatusBarMenuDelegate.swift
//  StatusBarMenuDelegate
//
//  Created by David Stephens on 17/09/2021.
//

import Cocoa

private extension MenuItem {
    static let open = MenuItem(title: String.localizedStringWithFormat(NSLocalizedString("OpenMI", tableName: "Mac", comment: "Open app"), Bundle.displayName), target: WindowManager.shared, action: #selector(WindowManager.openMain))
    static let quit = MenuItem(title: String.localizedStringWithFormat(NSLocalizedString("QuitMI", tableName: "Mac", comment: "quit"), Bundle.displayName), target: NSApp, action: #selector(NSApp.terminate(_:)))
}

class StatusBarMenuController: NSObject, NSMenuDelegate {
    static let shared = StatusBarMenuController()
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
        StatusItemController.shared.setButton(state: .off)
    }
}
