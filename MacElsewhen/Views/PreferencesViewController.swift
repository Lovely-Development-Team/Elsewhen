//
//  PreferencesViewController.swift
//  MacElsewhen
//
//  Created by David Stephens on 19/11/2021.
//

import Cocoa

class PreferencesViewController: NSViewController {
    @IBOutlet weak var shouldShowWidgetCheckbox: NSButton!
    @IBOutlet weak var shouldTerminateAfterLastWindowCheckbox: NSButton!
    
    @IBOutlet weak var defaultTimeZoneButton: NSButton!
    
    @IBOutlet weak var systemLocaleRadioButton: NSButton!
    @IBOutlet weak var twelveHourRadioButton: NSButton!
    @IBOutlet weak var twentyFourHourRadioButton: NSButton!
    
    @IBOutlet weak var hyphenRadioButton: NSButton!
    @IBOutlet weak var colonRadioButton: NSButton!
    @IBOutlet weak var noneRadioButton: NSButton!
    
    let defaultTzPopoverController = DefaultTimeZonePopoverController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        shouldShowWidgetCheckbox.state = UserDefaults.showMenuBarWidget ? .on : .off
        shouldTerminateAfterLastWindowCheckbox.state = UserDefaults.shouldTerminateAfterLastWindowClosed ? .on : .off
        switch UserDefaults.shared.mykeModeDefaultTimeFormat {
        case .systemLocale:
            systemLocaleRadioButton.state = .on
        case .twelve:
            twelveHourRadioButton.state = .on
        case .twentyFour:
            twentyFourHourRadioButton.state = .on
        }
        switch UserDefaults.shared.mykeModeSeparator {
        case .hyphen:
            hyphenRadioButton.state = .on
        case .colon:
            colonRadioButton.state = .on
        case .noSeparator:
            noneRadioButton.state = .on
        }
    }
    
    @IBAction func showInMenuBar(_ sender: NSButton) {
        UserDefaults.showMenuBarWidget = sender.state == .on
    }
    
    @IBAction func terminateAfterLastWindowClosed(_ sender: NSButton) {
        UserDefaults.shouldTerminateAfterLastWindowClosed = sender.state == .on
    }
    
    @IBAction func selectDefaultTimeZone(_ sender: NSButton) {
        defaultTzPopoverController.show(relativeTo: sender.visibleRect, of: sender, preferredEdge: .maxX)
    }
    
    @IBAction func defaultTimeFormat(_ sender: NSButton) {
        switch sender.tag {
        case 1:
            UserDefaults.shared.mykeModeDefaultTimeFormat = .systemLocale
        case 2:
            UserDefaults.shared.mykeModeDefaultTimeFormat = .twelve
        case 3:
            UserDefaults.shared.mykeModeDefaultTimeFormat = .twentyFour
        default:
            break
        }
    }
    
    @IBAction func mykeModeSeparator(_ sender: NSButton) {
        switch sender.tag {
        case 1:
            UserDefaults.shared.mykeModeSeparator = .hyphen
        case 2:
            UserDefaults.shared.mykeModeSeparator = .colon
        case 3:
            UserDefaults.shared.mykeModeSeparator = .noSeparator
        default:
            break
        }
    }
    
}
