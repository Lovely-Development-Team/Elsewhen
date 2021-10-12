//
//  ElsewhenApp.swift
//  Elsewhen
//
//  Created by Ben Cardy on 04/09/2021.
//

import SwiftUI
import UIKit
import Combine


enum DeviceOrientation: String {
    case portrait
    case landscape
}


class OrientationObserver: ObservableObject {
    
    static let shared = OrientationObserver()
    
    @Published var currentOrientation: DeviceOrientation = .portrait
    private var disposables: [AnyCancellable] = []
    
    init() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification, object: nil)
            .sink { notification in
                print("BEN: Orientation change notification received: \(notification)")
                if let device = notification.object as? UIDevice {
                    if device.orientation.isPortrait {
                        self.changeOrientation(to: .portrait)
                    } else {
                        self.changeOrientation(to: .landscape)
                    }
                }
            }
            .store(in: &disposables)
    }
    
    func changeOrientation(to orientation: DeviceOrientation) {
        print("BEN: Changing orientation to: \(orientation.rawValue)")
        currentOrientation = orientation
    }
    
}


@main
struct ElsewhenApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif
    
    init() {
        UserDefaults.shared.register(defaults: [
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
                .environmentObject(OrientationObserver.shared)
            #endif
        }
    }
}
