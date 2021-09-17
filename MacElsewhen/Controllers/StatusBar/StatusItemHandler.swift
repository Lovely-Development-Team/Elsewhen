//
//  StatusItemHandler.swift
//  StatusItemHandler
//
//  Created by David Stephens on 17/09/2021.
//

import Cocoa
import Combine

class StatusItemHandler: NSObject {
    static let shared: StatusItemHandler = StatusItemHandler()
    private(set) var statusItem: NSStatusItem? = nil
    var buttonWindow: NSWindow? {
        statusItem?.button?.window
    }
    let popoverDelegate = StatusBarPopoverDelegate()
    var preferenceCancellable: AnyCancellable?
    
    private override init() {
        super.init()
        observePreference()
    }
    
    private func observePreference() {
        preferenceCancellable = UserDefaults.standard.publisher(for: \.showMenuBarWidget)
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
        let image = NSImage(named: "Elsewhen")
        image?.size = NSSize(width: 18, height: 18)
        statusButton?.image = image
        statusButton?.sendAction(on: [.leftMouseDown, .rightMouseDown, .otherMouseDown, .directTouch])
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
            StatusBarMenuDelegate.shared.popupAtMouseLocation()
        } else {
            popoverDelegate.show(relativeTo: statusItem.button!.visibleRect, of: statusItem.button!)
        }
    }
    
    func setButton(state: NSControl.StateValue) {
        self.statusItem?.button?.state = state
    }
}
