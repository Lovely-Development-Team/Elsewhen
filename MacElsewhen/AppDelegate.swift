//
//  AppDelegate.swift
//  AppDelegate
//
//  Created by David Stephens on 17/09/2021.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var windowManager: WindowManager!
    var statusItemController: StatusItemController!
    let mainMenuController = MainMenuController()
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        self.windowManager = WindowManager.shared
        self.statusItemController = StatusItemController.shared
        let mainMenu = NSApp.mainMenu
        let appMenuItem = mainMenu?.item(at: 0)
        let appMenu = appMenuItem?.submenu
        // The delegate will handle menu customisation
        appMenu?.delegate = mainMenuController
        // Set identifiers so MainMenuController can recognise it easily
        appMenu?.identifier = MainMenuController.appMenuIdentifier
        let aboutItem = appMenu?.item(at: 0)
        aboutItem?.tag = MenuTag.about.rawValue
        let servicesItem = appMenu?.item(withTitle: "Services")
        servicesItem?.tag = MenuTag.services.rawValue
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let window = NSApp.orderedWindows.first { window in
            window.level == .normal
        }
        windowManager.initialWindowController = window?.windowController
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return UserDefaults.standard.shouldTerminateAfterLastWindowClosed
    }
}
