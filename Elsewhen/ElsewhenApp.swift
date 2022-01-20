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
        UserDefaults.shared.register(defaults: [
            UserDefaults.mykeModeTimeZoneIdentifiersKey: UserDefaults.defaultMykeModeTimeZoneIdentifiers,
            UserDefaults.mykeModeTimeZoneIdentifiersUsingEUFlagKey: Array(europeanUnionTimeZones),
            UserDefaults.lastSeenVersionForSettingsKey: AboutElsewhen.buildNumber,
        ])
    }
    
    var body: some Scene {
        WindowGroup {
            #if os(macOS)
            MacContentView()
            #else
            ContentView()
                .environmentObject(OrientationObserver.shared)
            #endif
        }
    }
}
