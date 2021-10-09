//
//  CommonResolution.swift
//  CommonResolution
//
//  Created by David on 08/10/2021.
//

import Foundation

func timezoneOptions(in category: INTimeZoneSourceCategory, for searchTerm: String?) -> [INTimezone] {
    let searchTerm = searchTerm ?? ""
    let timezones: [TimeZone]
    switch category {
    case .selected:
        let mykeModeTimezones = UserDefaults.shared.mykeModeTimeZones
        timezones = filter(timezones: mykeModeTimezones, by: searchTerm)
    case .favourites:
        let favouriteTimeZones = UserDefaults.shared.favouriteTimeZones
        timezones = filter(timezones: Array(favouriteTimeZones), by: searchTerm)
    default:
        timezones = TimeZone.filtered(by: searchTerm)
    }
    let convertedTimezones = timezones.map { INTimezone(from: $0) }
    return convertedTimezones
}
