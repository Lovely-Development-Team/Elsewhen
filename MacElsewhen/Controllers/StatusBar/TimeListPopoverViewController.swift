//
//  TimeListPopoverViewController.swift
//  MacElsewhen
//
//  Created by David Stephens on 22/11/2021.
//

import Cocoa
import SwiftUI

class TimeListPopoverViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mykeModeHostingView = NSHostingView(rootView: MykeMode(dateHolder: DateHolder.shared).frame(width: 400).frame(minHeight: 600).environmentObject(DateHolder.shared).environmentObject(NSUbiquitousKeyValueStoreController.shared).environment(\.isInPopover, true).environmentObject(NSUbiquitousKeyValueStoreController.shared))
        attach(subview: mykeModeHostingView, to: self.view)
        // Do view setup here.
    }
    
    private func attach(subview: NSView, to view: NSView) {
        view.addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        // Set the child controller's view to be the exact same size as the parent controller's view.
        subview.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        subview.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        subview.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        subview.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        subview.viewDidMoveToWindow()
        subview.viewDidMoveToSuperview()
    }
    
}
