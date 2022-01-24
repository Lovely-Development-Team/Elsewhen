//
//  PopoverTabViewController.swift
//  PopoverTabViewController
//
//  Created by David Stephens on 17/09/2021.
//

import Cocoa
import SwiftUI

class ContentTabViewController: NSTabViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSwiftUITab(containing: TimeCodeGeneratorView().padding(.top), label: "TimeCodeLabel", image: NSImage(systemSymbolName: "clock", accessibilityDescription: nil))
                
        addSwiftUITab(containing: MykeMode().padding(.top), label: "TimeListLabel", image: NSImage(systemSymbolName: "list.dash", accessibilityDescription: nil))
        
        tabStyle = .toolbar
        
    }
    
    override func viewWillAppear() {
        selectedTabViewItemIndex = Tab(rawValue: UserDefaults.standard.defaultTab)?.rawValue ?? 0
    }
    
    /**
     Adds a new tab contianing SwiftUI view
     
     - Parameters:
         - rootView: The `View` to use as the content.
         - label: The localised string key for the item's label.
         - image: The item's image.
     - Returns: `true` if item was found and configured, `false` otherwise.
     */
    private func addSwiftUITab<Root: View>(containing rootView: Root, label: String, image: NSImage?) {
        let vc = NSHostingController(rootView: rootView)
        addChild(vc)
        let wasConfigured = configure(for: vc, label: label, image: image)
        assert(wasConfigured, "\(label) should have been configured")
    }
    
    /**
     Configures the `NSTabViewItem` for this `NSViewController`
     
     - Parameters:
         - viewController: The `NSViewController` for which to configure the `NSTabViewItem`.
         - label: The localised string key for the item's label.
         - image: The item's image.
     - Returns: `true` if item was found and configured, `false` otherwise.
     */
    private func configure(for viewController: NSViewController, label: String, image: NSImage?) -> Bool {
        guard let tabItem = tabViewItem(for: viewController) else {
            return false
        }
        tabItem.label = NSLocalizedString(label, tableName: "Mac", comment: "")
        tabItem.image = image
        return true
    }
    
}

struct ContentViewControllerRepresentable: NSViewControllerRepresentable {
    typealias NSViewControllerType = NSTabViewController
    
    func makeNSViewController(context: Context) -> NSTabViewController {
        return ContentTabViewController()
    }
    
    func updateNSViewController(_ nsViewController: NSTabViewController, context: Context) {
    }
}
