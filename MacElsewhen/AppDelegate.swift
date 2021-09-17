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
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        self.windowManager = WindowManager.shared
        self.statusBarMenuDelegate = StatusBarMenuDelegate.shared
        self.statusItemHandler = StatusItemHandler.shared
    }
}
