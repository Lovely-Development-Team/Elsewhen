//
//  TimeCodesPopoverViewController.swift
//  MacElsewhen
//
//  Created by David Stephens on 22/11/2021.
//

import Cocoa
import SwiftUI

class TimeCodesPopoverViewController: NSViewController {

    var date: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let timeCodeHostingView = NSHostingView(rootView: TimeCodeGeneratorView(selectedDate: Binding(get: { self.date }, set: { [self] in self.date = $0 })).frame(width: 400).environment(\.isInPopover, true))
        attach(subview: timeCodeHostingView, to: self.view)
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
