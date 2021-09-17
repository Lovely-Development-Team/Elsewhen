//
//  AppDelegate.swift
//  AppDelegate
//
//  Created by David Stephens on 17/09/2021.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var windowManager: WindowManager!
    var statusBarMenuDelegate: StatusBarMenuDelegate?
    var statusItemHandler: StatusItemHandler?
    let mainMenuController = MainMenuController()
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        self.windowManager = WindowManager.shared
        self.statusBarMenuDelegate = StatusBarMenuDelegate.shared
        self.statusItemHandler = StatusItemHandler.shared
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
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return UserDefaults.standard.shouldTerminateAfterLastWindowClosed
    }
}
