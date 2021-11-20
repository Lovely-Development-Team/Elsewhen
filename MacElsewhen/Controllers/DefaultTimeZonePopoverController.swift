//
//  DefaultTimeZonePopover.swift
//  MacElsewhen
//
//  Created by David Stephens on 19/11/2021.
//

import Cocoa
import SwiftUI

class DefaultTimeZonePopoverController: NSObject, NSPopoverDelegate {
    var openPopover: NSPopover?
    var detachedWindows: Set<NSWindow> = Set()
    
    var defaultTimeZone: Binding<TimeZone?> {
        Binding {
            UserDefaults.shared.resetButtonTimeZone
        } set: { newValue in
            UserDefaults.shared.resetButtonTimeZone = newValue
        }
    }
    
    private func contentsViewController() -> NSViewController {
        let vc = NSHostingController(rootView: TimezoneChoiceView(selectedTimeZone: defaultTimeZone, selectedTimeZones: .constant([]), selectedDate: .constant(.distantPast), selectMultiple: false, showDeviceLocalOption: true) {
            self.openPopover?.close()
        }
        .frame(minWidth: 300, minHeight: 300).environment(\.isInPopover, true))
        return vc
    }
    
    func popover() -> NSPopover {
        if let existingPopover = openPopover {
            return existingPopover
        } else {
            let popover = NSPopover()
            popover.behavior = .transient
            popover.contentViewController = self.contentsViewController()
            popover.delegate = self
            openPopover = popover
            return popover
        }
    }

    // MARK: - Popover Delegate
    
    func popoverShouldDetach(_ popover: NSPopover) -> Bool {
        return true
    }
    
    func detachableWindow(for popover: NSPopover) -> NSWindow? {
        let window = NSWindow()
        window.contentViewController = self.contentsViewController()
        window.isMovableByWindowBackground = true
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.isReleasedWhenClosed = false
        return window
    }
    
    func popoverDidDetach(_ popover: NSPopover) {
        openPopover = nil
        guard let popoverWindow = popover.contentViewController?.view.window else {
            uiLogger.error("Detached popover did not have associated window")
            return
        }
        detachedWindows.insert(popoverWindow)
    }
    
    func popoverWillClose(_ notification: Notification) {
        guard let closeReason = notification.userInfo?[NSPopover.closeReasonUserInfoKey] as? NSPopover.CloseReason else {
            return
        }
        if closeReason == .standard {
            guard let popover = notification.object as? NSPopover else {
                uiLogger.error("Sender of popoverWillClose was not a popover!")
                return
            }
            guard let window = popover.contentViewController?.view.window else {
                uiLogger.warning("Could not find window associated with popover")
                return
            }
            detachedWindows.remove(window)
            openPopover = nil
        }
    }
    
    // MARK: - Actions
    func show(relativeTo positioningRect: NSRect, of positioningView: NSView, preferredEdge: NSRectEdge = .minY) {
        self.popover().show(relativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge)
    }
}
