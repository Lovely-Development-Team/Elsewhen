//
//  PreferencesWindowController.swift
//  PreferencesWindowController
//
//  Created by David Stephens on 17/09/2021.
//

import Cocoa
import os.log
import SwiftUI

class PreferencesWindowController: NSWindowController, NSWindowDelegate {
    static let windowIdentifier = NSUserInterfaceItemIdentifier("PreferencesWindow")
    

    init() {
        let window = NSWindow(contentViewController: PreferencesViewController())
        window.identifier = Self.windowIdentifier
        window.title = "Preferences"
        super.init(window: window)
        window.delegate = self
        self.windowFrameAutosaveName = "PreferencesWindow"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.restorationClass = WindowManager.self
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
}
