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
    
    @IBOutlet weak var mykeModeSeperatorLabel: NSTextField!
    @IBOutlet weak var hyphenRadioButton: NSButton!
    @IBOutlet weak var colonRadioButton: NSButton!
    @IBOutlet weak var noneRadioButton: NSButton!
    
    let defaultTzPopoverController = DefaultTimeZonePopoverController()
    
    private var resetButtonTimeZoneStringObservation: NSKeyValueObservation?
    
    static var defaultTimeZoneName: String {
        "Device (\(TimeZone.current.friendlyName))"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        shouldShowWidgetCheckbox.state = UserDefaults.showMenuBarWidget ? .on : .off
        shouldTerminateAfterLastWindowCheckbox.state = UserDefaults.shouldTerminateAfterLastWindowClosed ? .on : .off
        
        defaultTimeZoneButton.title = UserDefaults.shared.resetButtonTimeZone?.friendlyName ?? Self.defaultTimeZoneName
        
        resetButtonTimeZoneStringObservation = UserDefaults.shared.observe(\.resetButtonTimeZoneString) { [weak self] defaults, _ in
            self?.defaultTimeZoneButton.title = defaults.resetButtonTimeZone?.friendlyName ?? Self.defaultTimeZoneName
        }
        
        switch UserDefaults.shared.mykeModeDefaultTimeFormat {
        case .systemLocale:
            systemLocaleRadioButton.state = .on
        case .twelve:
            twelveHourRadioButton.state = .on
        case .twentyFour:
            twentyFourHourRadioButton.state = .on
        }
        
        var buttons: [NSButton] = []
        for idx in MykeModeSeparator.allCases.indices {
            let separator = MykeModeSeparator.allCases[idx]
            let radioButton = NSButton(radioButtonWithTitle: separator.description, target: self, action: #selector(mykeModeSeparator(_:)))
            radioButton.translatesAutoresizingMaskIntoConstraints = false
            radioButton.tag = idx
            buttons.append(radioButton)
            self.view.addSubview(radioButton)
            radioButton.leadingAnchor.constraint(equalTo: twentyFourHourRadioButton.leadingAnchor).isActive = true
            if idx != MykeModeSeparator.allCases.startIndex {
                radioButton.topAnchor.constraint(equalToSystemSpacingBelow: buttons[buttons.index(before:idx)].bottomAnchor, multiplier: 1).isActive = true
            }
            if separator == UserDefaults.shared.mykeModeSeparator {
                radioButton.state = .on
            }
        }
        buttons.first!.centerYAnchor.constraint(equalTo: mykeModeSeperatorLabel.centerYAnchor).isActive = true
        self.view.bottomAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: buttons.last!.bottomAnchor, multiplier: 1).isActive = true
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
        UserDefaults.shared.mykeModeSeparator = MykeModeSeparator.allCases[sender.tag]
    }
    
}
