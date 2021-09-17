//
//  WindowManager.swift
//  WindowManager
//
//  Created by David Stephens on 17/09/2021.
//

import Cocoa
import Combine
import SwiftUI

class WindowManager: NSObject, NSWindowRestoration {
    deinit {
        print("Windowmanager deinit")
    }
    
    static func restoreWindow(withIdentifier identifier: NSUserInterfaceItemIdentifier, state: NSCoder, completionHandler: @escaping (NSWindow?, Error?) -> Void) {
        if identifier.rawValue == "Preferences" {
            completionHandler(Self.shared.createPrefsWindow(), nil)
            return
        } else {
            completionHandler(nil, nil)
            return
        }
    }
    
    static let shared = WindowManager()
    var initialWindowController: NSWindowController?
    private var prefsWindowController: NSWindowController? = NSApp.windows.first { $0.title == "Preferences" }?.windowController
    
    private var allWindowsWillCloseCancellable: AnyCancellable? = nil
    private var prefsWindowWillCloseCancellable: AnyCancellable? = nil
    
    private override init() {
        super.init()
        observePrefs()
        observeWindowClose()
    }
    
    /**
     Subscribes to window closure notifications so we can remove/add our dock icon when necessary.
     */
    private func observeWindowClose() {
        allWindowsWillCloseCancellable = NotificationCenter.default.publisher(for: NSWindow.willCloseNotification, object: nil)
            .compactMap { notification -> NSWindow? in
                // This should always succeed, but best not to assume
                guard let notifyingObject = notification.object as? NSWindow else {
                    uiLogger.error("Sender of willCloseNotification was not an NSWindow!")
                    return nil
                }
                return notifyingObject
            }
        // Menus, the status bar item, etc all count as windows closing but shouldn't trigger the mode swift
            .filter { $0.level == .normal }
            .sink { closingWindow in
                // The window that's currently closing shouldn't be included in our count
                let normalWindows = NSApp.windows.filter { $0 != closingWindow }
                if normalWindows.count == 1 && normalWindows[0].identifier == StatusItemController.windowIdentifier {
                    // There's only one window and it's the status bar, we should remove our dock icon.
                    NSApp.setActivationPolicy(.accessory)
                } else if (NSApp.activationPolicy() != .regular) {
                    // In any other scenario, we should have a dock icon
                    NSApp.setActivationPolicy(.regular)
                }
            }
    }
    
    /**
     Subscribes to pref window closure so we can nil the reference and allow it to be de-allocated.
     */
    private func observePrefs() {
        guard let prefsWindow = prefsWindowController?.window else {
            return
        }
        prefsWindowWillCloseCancellable = NotificationCenter.default.publisher(for: NSWindow.willCloseNotification, object: prefsWindow)
            .sink { [weak self] notification in
                guard let notifyingObject = notification.object as? NSWindow else {
                    uiLogger.error("Sender of willCloseNotification was not an NSWindow!")
                    return
                }
                if notifyingObject.identifier == self?.prefsWindowController?.window?.identifier {
                    self?.prefsWindowController = nil
                }
            }
    }
    
    private func createPrefsWindow() -> NSWindow? {
        let controller: NSWindowController
        // If we already have a pefsWindowController, preferences is already open and we should bring that forward
        if let existingController = self.prefsWindowController {
            controller = existingController
        } else {
            controller = PreferencesWindowController()
            self.prefsWindowController = controller
            observePrefs()
        }
        return controller.window
    }
    
    /**
     Find the "primary"
     */
    private func findPrimaryWindow() -> NSWindow? {
        if let mainWindow = NSApp.mainWindow {
            return mainWindow
        }
        // If there's no main window, we'll take the frontmost "normal" window
        if let firstWindow =  NSApp.orderedWindows.first(where: { window in
            window.level == .normal
        }) {
            return firstWindow
        }
        // We haven't found any appropriate windows; hand back the window from when the app was initially opened
        return initialWindowController?.window
    }
    
    @objc func openMain() {
        if NSApp.activationPolicy() != .regular {
            NSApp.setActivationPolicy(.regular)
        }
        let firstNormalWindow = self.findPrimaryWindow()
        firstNormalWindow?.makeKeyAndOrderFront(self)
        if !NSApp.isActive {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    @objc func openPreferences() {
        let window = createPrefsWindow()
        NSApp.activate(ignoringOtherApps: true)
        // We should probably be doing more to remember window position, but for now we'll just centre it.
        if window?.isVisible == false {
            window?.center()
        }
        window?.makeKeyAndOrderFront(self)
    }
    
    func closePreferences() {
        prefsWindowController?.close()
    }
}
