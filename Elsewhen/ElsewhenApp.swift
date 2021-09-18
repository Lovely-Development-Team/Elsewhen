//
//  ElsewhenApp.swift
//  Elsewhen
//
//  Created by Ben Cardy on 04/09/2021.
//

import SwiftUI

@main
struct ElsewhenApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif
    
    init() {
        UserDefaults.standard.register(defaults: [
            UserDefaults.mykeModeTimeZoneIdentifiersKey: [
                "America/Los_Angeles",
                "America/Chicago",
                "America/New_York",
                "Europe/London",
                "Europe/Rome",
            ],
            UserDefaults.mykeModeTimeZoneIdentifiersUsingEUFlagKey: Array(europeanUnionTimeZones),
        ])
    }
    
    var body: some Scene {
        WindowGroup {
            #if os(macOS)
            MacContentView()
            #else
            ContentView()
            #endif
        }
    }
}
