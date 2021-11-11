//
//  StatusItemHandler.swift
//  StatusItemHandler
//
//  Created by David Stephens on 17/09/2021.
//

import Cocoa
import Combine

class StatusItemController: NSObject {
    static let windowIdentifier = NSUserInterfaceItemIdentifier("StatusItem")
    
    static let shared: StatusItemController = StatusItemController()
    
    private var statusItem: NSStatusItem? = nil
    var buttonWindow: NSWindow? {
        statusItem?.button?.window
    }
    let popoverDelegate = StatusBarPopoverController()
    let menuDelegate = StatusBarMenuController()
    var preferenceCancellable: AnyCancellable?
    
    private override init() {
        super.init()
        observePreference()
    }
    
    private func observePreference() {
        preferenceCancellable = UserDefaults.showMenuBarWidgetPublisher
            .sink { [unowned self] shouldShow in
                if shouldShow && statusItem == nil {
                    addItem()
                } else if !shouldShow && statusItem != nil {
                    removeItem()
                }
            }
    }
    
    private func addItem() {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let statusButton = statusItem.button
        statusButton?.target = self
        statusButton?.action = #selector(onClick)
        statusButton?.title = Bundle.displayName
        let image = NSImage(named: "ElsewhenStatusItem")
        image?.size = NSSize(width: 18, height: 18)
        statusButton?.image = image
        statusButton?.sendAction(on: [.leftMouseDown, .rightMouseDown, .otherMouseDown, .directTouch])
        statusButton?.window?.identifier = Self.windowIdentifier
        self.statusItem = statusItem
    }
    
    private func removeItem() {
        self.statusItem = nil
    }
    
    @objc func onClick() {
        guard let event = NSApp.currentEvent else {
            uiLogger.error("Received action with no event")
            return
        }
        guard let statusItem = statusItem else {
            uiLogger.error("Click received but no status item retained!")
            return
        }
        if event.isRightClick || event.isOtherClick {
            menuDelegate.popupAtMouseLocation()
        } else {
            popoverDelegate.show(relativeTo: statusItem.button!.visibleRect, of: statusItem.button!)
        }
    }
    
    func setButton(state: NSControl.StateValue) {
        self.statusItem?.button?.state = state
        self.statusItem?.button?.highlight(false)
    }
}
