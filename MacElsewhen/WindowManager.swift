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
    private var prefsWindowController: NSWindowController? = NSApp.windows.first { $0.title == "Preferences" }?.windowController
    
    private var cancellables: [AnyCancellable] = []
    
    private override init() {
        super.init()
        observePrefs()
        NotificationCenter.default.publisher(for: NSWindow.willCloseNotification, object: nil)
            .sink { [weak self] notification in
                guard let notifyingObject = notification.object as? NSWindow else {
                    uiLogger.error("Sender of willCloseNotification was not an NSWindow!")
                    return
                }
                let windows = NSApp.windows.filter { window in
                    window != notifyingObject
                }
                if windows.count == 1 && windows.first == StatusItemHandler.shared.statusItem.button?.window {
                    NSApp.setActivationPolicy(.accessory)
                } else if (NSApp.activationPolicy() != .regular) {
                    NSApp.setActivationPolicy(.regular)
                }
            }
            .store(in: &cancellables)
    }
    
    private func observePrefs() {
        guard let prefsWindow = prefsWindowController?.window else {
            return
        }
        NotificationCenter.default.publisher(for: NSWindow.willCloseNotification, object: prefsWindow)
            .sink { [weak self] notification in
                guard let notifyingObject = notification.object as? NSWindow else {
                    uiLogger.error("Sender of willCloseNotification was not an NSWindow!")
                    return
                }
                if notifyingObject.identifier == self?.prefsWindowController?.window?.identifier {
                    self?.prefsWindowController = nil
                }
            }
            .store(in: &cancellables)
    }
    
    private func createPrefsWindow() -> NSWindow? {
        StatusItemHandler.shared.statusItem.button?.state = .off
        let controller: NSWindowController
        if let existingController = self.prefsWindowController {
            controller = existingController
        } else {
            controller = PreferencesWindowController()
            self.prefsWindowController = controller
            observePrefs()
        }
        return controller.window
    }
    
    @objc func openMain() {
        let window = NSApp.mainWindow
        NSApp.activate(ignoringOtherApps: true)
        window?.center()
        window?.makeKeyAndOrderFront(self)
    }
    
    @objc func openPreferences() {
        let window = createPrefsWindow()
        NSApp.activate(ignoringOtherApps: true)
        window?.center()
        window?.makeKeyAndOrderFront(self)
    }
    
    func closePreferences() {
        prefsWindowController?.close()
    }
}
