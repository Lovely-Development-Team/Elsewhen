//
//  TimeCodesPopoverViewController.swift
//  MacElsewhen
//
//  Created by David Stephens on 22/11/2021.
//

import Cocoa
import SwiftUI

class TimeZonePopoverData: ObservableObject {
    @Published var selectedDate: Date
    @Published var selectedTimeZone: TimeZone?
    @Published var selectedFormatStyle: DateFormat
    @Published var showLocalTimeInstead: Bool
    @Published var appendRelative: Bool
    
    init(selectedDate: Date, selectedTimeZone: TimeZone?, formatStyle: DateFormat, showLocalTimeInstead: Bool, appendRelative: Bool) {
        self.selectedDate = selectedDate
        self.selectedTimeZone = selectedTimeZone
        self.selectedFormatStyle = formatStyle
        self.showLocalTimeInstead = showLocalTimeInstead
        self.appendRelative = appendRelative
    }
}

struct DateTimeSelectionContainerView: View {
    @ObservedObject var data: TimeZonePopoverData
    
    var body: some View {
        DateTimeSelection(selectedFormatStyle: $data.selectedFormatStyle.animation(), selectedDate: $data.selectedDate, selectedTimeZone: $data.selectedTimeZone, appendRelative: $data.appendRelative.animation(), showLocalTimeInstead: $data.showLocalTimeInstead)
            .frame(maxWidth: 400)
            .environment(\.isInPopover, true)
    }
}

struct FormattedDateAndWarningContainerView: View {
    @ObservedObject var data: TimeZonePopoverData
    @State private var showEasterEggSheet: Bool = false
    
    private var discordFormatString: String {
        return discordFormat(for: data.selectedDate, in: data.selectedTimeZone ?? TimeZone.current, with: data.selectedFormatStyle.code, appendRelative: data.appendRelative)
    }
    
    var body: some View {
        FormattedDateAndWarning(display: discordFormatString, showEasterEggSheet: $showEasterEggSheet)
            .frame(maxWidth: 430)
            .fixedSize(horizontal: false, vertical: true)
            .environment(\.isInPopover, true)
            .sheet(isPresented: $showEasterEggSheet) {
                EasterEggView().environment(\.isInPopover, true)
            }
    }
}

class TimeCodesPopoverViewController: NSViewController {
    @IBOutlet weak var dateTimeSelectionContainer: NSView!
    @IBOutlet weak var resultSheetContainer: NSView!
    
    let data = TimeZonePopoverData(selectedDate: Date(), selectedTimeZone: nil, formatStyle: dateFormats[0], showLocalTimeInstead: false, appendRelative: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dateSelectionHostingView = NSHostingView(rootView: DateTimeSelectionContainerView(data: data))
        attach(subview: dateSelectionHostingView, to: dateTimeSelectionContainer)
        let resultSheetHostingView = NSHostingView(rootView: FormattedDateAndWarningContainerView(data: data))
        attach(subview: resultSheetHostingView, to: resultSheetContainer)
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
