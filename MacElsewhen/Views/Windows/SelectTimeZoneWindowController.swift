//
//  SelectTimeZoneWindowController.swift
//  SelectTimeZoneWindowController
//
//  Created by David on 21/09/2021.
//

import Cocoa
import SwiftUI

class SelectTimeZoneWindowController: NSWindowController {
    static let windowIdentifier = NSUserInterfaceItemIdentifier("SelectTimeZoneWindow")
    
    static let defaultWidth: CGFloat = 200
    static let defaultHeight: CGFloat = 200
    
    @Binding var selectedTimeZone: TimeZone
    @Binding var selectedDate: Date
    @Binding var selectedTimeZones: [TimeZone]
    var height: CGFloat?
    
    init(selectedTimeZone: Binding<TimeZone>, selectedDate: Binding<Date>, selectedTimeZones: Binding<[TimeZone]>?, height: CGFloat? = SelectTimeZoneWindowController.defaultHeight) {
        self._selectedTimeZone = selectedTimeZone
        self._selectedDate = selectedDate
        let selectedTimeZonesInput = selectedTimeZones ?? Binding.constant([])
        self._selectedTimeZones = selectedTimeZonesInput
        self.height = height
        let rootView = Self.createChoiceView(selectedTimeZone: selectedTimeZone, selectedDate: selectedDate, selectedTimeZones: selectedTimeZonesInput, selectMultiple: selectedTimeZones != nil, height: height)
        let content = NSHostingView(rootView: rootView)
        let window = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: Self.defaultWidth, height: height!),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .utilityWindow],
            backing: .buffered, defer: false)
        window.identifier = Self.windowIdentifier
        window.title = selectedTimeZones == nil ? "Select a Time Zone" : "Select Time Zones"
        window.becomesKeyOnlyIfNeeded = true
        window.restorationClass = WindowManager.self
        window.contentView = content
        super.init(window: window)
        self.windowFrameAutosaveName = "SelectTimeZoneWindow"
    }
    
    private static func createChoiceView(selectedTimeZone: Binding<TimeZone>, selectedDate: Binding<Date>, selectedTimeZones: Binding<[TimeZone]>, selectMultiple: Bool, height: CGFloat?) -> some View {
        return (TimezoneChoiceView(selectedTimeZone: selectedTimeZone, selectedTimeZones: selectedTimeZones, selectedDate: selectedDate, selectMultiple: selectMultiple) {}).frame(minWidth: self.defaultWidth, idealWidth: self.defaultWidth, maxWidth: nil, minHeight: self.defaultHeight, idealHeight: height)
    }
    
    func updateBindings(selectedTimeZone: Binding<TimeZone>, selectedDate: Binding<Date>, selectedTimeZones: Binding<[TimeZone]>?) {
        self._selectedTimeZone = selectedTimeZone
        self._selectedDate = selectedDate
        let selectedTimeZonesInput = selectedTimeZones ?? Binding.constant([])
        self._selectedTimeZones = selectedTimeZonesInput
        let rootView = Self.createChoiceView(selectedTimeZone: selectedTimeZone, selectedDate: selectedDate, selectedTimeZones: selectedTimeZonesInput, selectMultiple: selectedTimeZones != nil, height: self.height)
        contentViewController = NSHostingController(rootView: rootView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
}
