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
    
    private var cancellables: [AnyCancellable] = []
    
    private override init() {
        super.init()
        observePrefs()
        NotificationCenter.default.publisher(for: NSWindow.willCloseNotification, object: nil)
            .sink { notification in
                guard let notifyingObject = notification.object as? NSWindow else {
                    uiLogger.error("Sender of willCloseNotification was not an NSWindow!")
                    return
                }
                let windows = NSApp.windows.filter { window in
                    window != notifyingObject
                }
                if windows.count == 1 && windows.first?.identifier == StatusItemController.windowIdentifier {
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
    
    private func findPrimaryWindow() -> NSWindow? {
        if let mainWindow = NSApp.mainWindow {
            return mainWindow
        }
        if let firstWindow =  NSApp.orderedWindows.first(where: { window in
            window.level == .normal
        }) {
            return firstWindow
        }
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
        window?.center()
        window?.makeKeyAndOrderFront(self)
    }
    
    func closePreferences() {
        prefsWindowController?.close()
    }
}
