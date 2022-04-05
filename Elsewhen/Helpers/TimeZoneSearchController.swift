//
//  CLTimeZoneSearchController.swift
//  Elsewhen
//
//  Created by Ben Cardy on 09/01/2022.
//

import SwiftUI
import Combine
import CoreLocation

class TimeZoneSearchController: ObservableObject {
    
    private let geocoder = CLGeocoder()
    
    @Published var results: Set<TimeZone> = []
    private var pendingTimeZoneSearchWorkItem: DispatchWorkItem? = nil
    @Published var lowPowerMode: Bool = false
    
    init() {
        if #available(macOS 12, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(powerStateChanged), name: Notification.Name.NSProcessInfoPowerStateDidChange, object: nil)
            self.lowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
        }
    }
    
    deinit {
        cancelPending()
    }
    
    @objc
    @available(macOS 12, *)
    func powerStateChanged(_ notification: Notification) {
        DispatchQueue.main.async {
            self.lowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
        }
    }

    private var delay: Double {
        if lowPowerMode {
            return 1.0
        } else {
            return 0.2
        }
    }
    
    func cancelPending() {
        pendingTimeZoneSearchWorkItem?.cancel()
        results = []
    }
    
    func search(for term: String) {
        let searchRequestWorkItem = DispatchWorkItem { [self] in
            geocoder.geocodeAddressString(term) { [self] searchResults, error in
                self.results = []
                if let searchResults = searchResults {
                    for result in searchResults {
                        if let tz = result.timeZone {
                            self.results.insert(tz)
                        }
                    }
                }
            }
        }
        pendingTimeZoneSearchWorkItem = searchRequestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: searchRequestWorkItem)
    }
    
}
