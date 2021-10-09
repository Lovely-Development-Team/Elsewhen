//
//  TimeZone.swift
//  TimeZone
//
//  Created by David on 09/10/2021.
//

import Foundation

extension TimeZone {
    
    var friendlyName: String {
        identifier.replacingOccurrences(of: "_", with: " ")
    }
    
    var flag: String {
        flagForTimeZone(self)
    }
    
    var isMemberOfEuropeanUnion: Bool {
        europeanUnionTimeZones.contains(self.identifier)
    }
    
    static func filtered(by searchTerm: String) -> [TimeZone] {
        let timezones = TimeZone.knownTimeZoneIdentifiers.compactMap { tz in
            TimeZone(identifier: tz)
        }
        return filter(timezones: timezones, by: searchTerm)
    }
    
    func matches(searchTerm: String) -> Bool {
        let st = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if st == "" {
            return true
        }
        if identifier.lowercased().contains(st) || friendlyName.lowercased().contains(st) {
            return true
        }
        if let abbreviation = abbreviation(), abbreviation.lowercased().contains(st) {
            return true
        }
        if identifier.starts(with: "America/") {
            if let localizedName = localizedName(for: .generic, locale: Locale(identifier: "en_US")), localizedName.lowercased().contains(st) {
                return true
            }
        }
        return false
    }
    
    func fudgedAbbreviation(for selectedDate: Date) -> String? {
        
        if identifier.starts(with: "America/") {
            if let localizedName = localizedName(for: .generic
                                                                                     , locale: Locale(identifier: "en_US")) {
                return localizedName.replacingOccurrences(of: " Time", with: "")
            }
        }
        
        guard let abbreviation = abbreviation(for: selectedDate) else { return nil }
        let isDaylightSavingTime = isDaylightSavingTime(for: selectedDate)
        if identifier == "Europe/London" && isDaylightSavingTime {
            return "BST"
        }
        
        if identifier.starts(with: "Europe") {
            if isDaylightSavingTime && abbreviation == "GMT+2" || !isDaylightSavingTime && abbreviation == "GMT+1" {
                return "CET"
            }
        }
        
        return abbreviation
        
    }
    
}
