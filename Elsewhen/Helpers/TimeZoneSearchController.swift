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

    func cancelPending() {
        pendingTimeZoneSearchWorkItem?.cancel()
        results = []
    }
    
    func search(for term: String) {
        let searchRequestWorkItem = DispatchWorkItem { [self] in
            geocoder.geocodeAddressString(term) { searchResults, error in
                results = []
                if let searchResults = searchResults {
                    for result in searchResults {
                        if let tz = result.timeZone {
                            results.insert(tz)
                        }
                    }
                }
            }
        }
        pendingTimeZoneSearchWorkItem = searchRequestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: searchRequestWorkItem)
    }
    
}
