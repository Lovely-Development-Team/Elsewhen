//
//  ElsewhenApp.swift
//  Elsewhen
//
//  Created by Ben Cardy on 04/09/2021.
//

import SwiftUI

@main
struct ElsewhenApp: App {
    
    init() {
        UserDefaults.standard.register(defaults: [
            UserDefaults.mykeModeTimeZoneIdentifiersKey: [
                "America/Los_Angeles",
                "America/Chicago",
                "America/New_York",
                "Europe/London",
                "Europe/Rome",
            ],
            UserDefaults.mykeModeTimeZoneIdentifiersUsingEUFlagKey: [
                "Europe/Rome",
            ],
        ])
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
