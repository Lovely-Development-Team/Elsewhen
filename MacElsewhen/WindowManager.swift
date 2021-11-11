//
//  WindowManager.swift
//  WindowManager
//
//  Created by David Stephens on 17/09/2021.
//

import Cocoa
import Combine
import SwiftUI

class WindowManager: NSObject, NSWindowRestoration, NSWindowDelegate {
    deinit {
        print("Windowmanager deinit")
    }
    
    static func restoreWindow(withIdentifier identifier: NSUserInterfaceItemIdentifier, state: NSCoder, completionHandler: @escaping (NSWindow?, Error?) -> Void) {
        if identifier == PreferencesWindowController.windowIdentifier {
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
    private var selectTimeZoneWindowController: SelectTimeZoneWindowController? = nil
    
    private var allWindowsWillCloseCancellable: AnyCancellable? = nil
    private var cancellables: [AnyCancellable] = []
    private var prefsWindowWillCloseCancellable: AnyCancellable? = nil
    
    private override init() {
        super.init()
        observeWindowController(at: \.prefsWindowController)
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
     Subscribes to window closure so we can nil the reference and allow it to be de-allocated.
     */
    private func observeWindowController<ControllerType: NSWindowController>(at path: ReferenceWritableKeyPath<WindowManager, ControllerType?>) {
        guard let prefsWindow = self[keyPath: path]?.window else {
            return
        }
        NotificationCenter.default.publisher(for: NSWindow.willCloseNotification, object: prefsWindow)
            .sink { [weak self] notification in
                guard let notifyingObject = notification.object as? NSWindow else {
                    uiLogger.error("Sender of willCloseNotification was not an NSWindow!")
                    return
                }
                if notifyingObject.identifier == self?[keyPath: path]?.window?.identifier {
                    self?[keyPath: path] = nil
                }
            }
            .store(in: &cancellables)
    }
    
    private func createRetainedWindow<ControllerType: NSWindowController>(assignTo path: ReferenceWritableKeyPath<WindowManager, ControllerType?>, _ newController: () -> ControllerType) -> NSWindow? {
        let controller: ControllerType
        // If we already have an NSWindowController, window is already open and we should bring that forward
        if let existingController = self[keyPath: path] {
            controller = existingController
        } else {
            controller = newController()
            self[keyPath: path] = controller
        }
        return controller.window
    }
    
    private func createPrefsWindow() -> NSWindow? {
        let window = createRetainedWindow(assignTo: \.prefsWindowController) {
            PreferencesWindowController()
        }
        observeWindowController(at: \.prefsWindowController)
        return window
    }
    
    private func createTimeZonesWindow(selectedTimeZone: Binding<TimeZone?>, selectedDate: Binding<Date>, selectedTimeZones: Binding<[TimeZone]>?) -> NSWindow? {
        let window = createRetainedWindow(assignTo: \.selectTimeZoneWindowController) {
            let primaryWindow = findPrimaryWindow()
            let primaryWindowHeight = primaryWindow?.frame.height
            let windowController = SelectTimeZoneWindowController(selectedTimeZone: selectedTimeZone, selectedDate: selectedDate, selectedTimeZones: selectedTimeZones, height: primaryWindowHeight )
            guard let newWindow = windowController.window else {
                uiLogger.error("New SelectTimeZoneWindowController has no window!")
                return windowController
            }
            primaryWindow?.addChildWindow(newWindow, ordered: .above)
            return windowController
        }
        self.selectTimeZoneWindowController?.updateBindings(selectedTimeZone: selectedTimeZone, selectedDate: selectedDate, selectedTimeZones: selectedTimeZones)
        window?.delegate = self
        return window
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
        window?.makeKeyAndOrderFront(self)
    }
    
    func openSelectTimeZones(selectedTimeZone: Binding<TimeZone?>, selectedDate: Binding<Date>, selectedTimeZones: Binding<[TimeZone]>? = nil) {
        let newWindow = createTimeZonesWindow(selectedTimeZone: selectedTimeZone, selectedDate: selectedDate, selectedTimeZones: selectedTimeZones)
        assert(newWindow != nil, "Window should have been created")
        guard let newWindow = newWindow else {
            return
        }
        if let primaryWindowFrame = findPrimaryWindow()?.frame {
            let selectTimeZonesSize = CGSize(width: newWindow.frame.width, height: primaryWindowFrame.height)
            if UserDefaults.standard.object(forKey: "NSWindow Frame \(newWindow.frameAutosaveName)") == nil || !newWindow.isOnActiveSpace {
                let primaryWindowRightY = primaryWindowFrame.origin.y
                let primaryWindowRightX = primaryWindowFrame.origin.x + primaryWindowFrame.width
                let panelFrame = NSRect(origin: NSPoint(x: primaryWindowRightX + 1, y: primaryWindowRightY), size: selectTimeZonesSize)
                newWindow.setFrame(panelFrame, display: true, animate: false)
            }
        }
        newWindow.makeKeyAndOrderFront(self)
    }
    
    func closePreferences() {
        prefsWindowController?.close()
    }
}
