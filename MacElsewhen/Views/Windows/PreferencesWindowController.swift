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
    
    static let width: CGFloat = 400
    static let height: CGFloat = 200
    
    init() {
        let content = NSHostingController(rootView: Text("Preferences here").frame(minWidth: Self.width, maxWidth: .infinity, minHeight: Self.height, maxHeight: .infinity))
        let window = NSWindow(contentViewController: content)
        window.identifier = NSUserInterfaceItemIdentifier("Preferences-\(UUID().uuidString)")
        window.title = "Preferences"
//        window.setContentSize(NSSize(width: Self.width, height: Self.height))
        window.setFrameAutosaveName("PreferencesWindow")
        super.init(window: window)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        self.windowFrameAutosaveName = "PreferencesWindow"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.shouldCascadeWindows = false
        self.window?.restorationClass = WindowManager.self
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

}
