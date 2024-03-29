//
//  TimeCodesPopoverViewController.swift
//  MacElsewhen
//
//  Created by David Stephens on 22/11/2021.
//

import Cocoa
import SwiftUI

class TimeCodesPopoverViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let timeCodeHostingView = NSHostingView(rootView: TimeCodeGeneratorView(dateHolder: DateHolder.shared).frame(width: 400).frame(minHeight: 600).environment(\.isInPopover, true).environmentObject(NSUbiquitousKeyValueStoreController.shared))
        attach(subview: timeCodeHostingView, to: self.view)
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
