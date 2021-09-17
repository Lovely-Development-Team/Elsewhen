//
//  StatusItemHandler.swift
//  StatusItemHandler
//
//  Created by David Stephens on 17/09/2021.
//

import Cocoa

class StatusItemHandler: NSObject {
    static let shared: StatusItemHandler = StatusItemHandler()
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let popoverDelegate = StatusBarPopoverDelegate()
    
    private override init() {
        super.init()
        let statusButton = statusItem.button
        statusButton?.target = self
        statusButton?.action = #selector(onClick)
        statusButton?.title = Bundle.displayName
        statusButton?.sendAction(on: [.leftMouseDown, .rightMouseDown, .otherMouseDown, .directTouch])
    }
    
    @objc func onClick() {
        guard let event = NSApp.currentEvent else {
            uiLogger.error("Received action with no event")
            return
        }
        if event.isRightClick || event.isOtherClick {
            StatusBarMenuDelegate.shared.popupAtMouseLocation()
        } else {
            popoverDelegate.show(relativeTo: statusItem.button!.visibleRect, of: statusItem.button!)
        }
    }
}
