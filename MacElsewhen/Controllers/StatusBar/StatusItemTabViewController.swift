//
//  StatusItemTabViewController.swift
//  MacElsewhen
//
//  Created by David Stephens on 22/11/2021.
//

import Cocoa

class StatusItemTabViewController: NSTabViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let timeCoesViewController = TimeCodesPopoverViewController()
        addChild(timeCoesViewController)
        configure(for: timeCoesViewController, label: "TimeCodeLabel", image: NSImage(systemSymbolName: "clock", accessibilityDescription: nil))
        let timeListViewController = TimeListPopoverViewController()
        addChild(timeListViewController)
        configure(for: timeListViewController, label: "TimeListLabel", image: NSImage(systemSymbolName: "list.dash", accessibilityDescription: nil))
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        selectedTabViewItemIndex = Tab(rawValue: UserDefaults.standard.defaultTab)?.rawValue ?? 0
    }
    
    /**
     Configures the `NSTabViewItem` for this `NSViewController`
     
     - Parameters:
         - viewController: The `NSViewController` for which to configure the `NSTabViewItem`.
         - label: The localised string key for the item's label.
         - image: The item's image.
     - Returns: `true` if item was found and configured, `false` otherwise.
     */
    private func configure(for viewController: NSViewController, label: String, image: NSImage?) {
        guard let tabItem = tabViewItem(for: viewController) else {
            return
        }
        tabItem.label = NSLocalizedString(label, tableName: "Mac", comment: "")
        tabItem.image = image
    }
}
