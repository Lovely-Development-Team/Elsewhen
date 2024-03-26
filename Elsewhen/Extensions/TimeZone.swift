//
//  TimeZone.swift
//  TimeZone
//
//  Created by David on 09/10/2021.
//

import Foundation

extension TimeZone {
    
    var friendlyName: String {
        if identifier == "GMT" {
            return "UTC / GMT"
        }
        return identifier.replacingOccurrences(of: "_", with: " ")
    }
    
    var country: String? {
        timeZoneCountries[identifier]
    }
    
    var city: String {
        friendlyName.components(separatedBy: "/").last ?? friendlyName
    }
    
    var alternativeSearchTerms: [String] {
        alternativeTimeZoneSearchTerms[identifier] ?? []
    }
    
    var flag: String {
        flagForTimeZone(self)
    }
    
    var isMemberOfEuropeanUnion: Bool {
        europeanUnionTimeZones.contains(self.identifier)
    }
    
    static var allTimeZoneIdentifiers: [String] {
        return Set(knownTimeZoneIdentifiers).union(abbreviationDictionary.keys).sorted()
    }
    
    static func filtered(by searchTerm: String, onDate: Date = Date()) -> [TimeZone] {
        let timezones = TimeZone.allTimeZoneIdentifiers.compactMap { tz in
            TimeZone(identifier: tz)
        }
        return filter(timezones: timezones, by: searchTerm, onDate: onDate)
    }
    
    func matches(searchTerm: String, onDate: Date = Date()) -> Bool {
        let st = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard st != "" else { return true }
        let alternativeSearchTerm = st.replacingOccurrences(of: "_", with: " ")
        if identifier.lowercased().contains(st) || friendlyName.lowercased().contains(st) {
            return true
        }
        if let abbreviation = abbreviation(), abbreviation.lowercased().contains(st) {
            return true
        }
        if let fudgedAbbreviation = fudgedAbbreviation(for: onDate), fudgedAbbreviation.lowercased().contains(st) {
            return true
        }
        if identifier.starts(with: "America/") {
            if let localizedName = localizedName(for: .generic, locale: Locale(identifier: "en_US")), localizedName.lowercased().contains(st) {
                return true
            }
        }
        if let country = country {
            let countryLower = country.lowercased()
            if countryLower.contains(st) || countryLower.contains(alternativeSearchTerm) {
                return true
            }
        }
        if !alternativeSearchTerms.filter({ term in
            let termLower = term.lowercased()
            return termLower.contains(st) || termLower.contains(alternativeSearchTerm)
        }).isEmpty {
            return true
        }
        return false
    }
    
    func fudgedAbbreviation(for selectedDate: Date = Date(), usingShort: Bool = false) -> String? {
        
        // India Standard Time should always say IST
        if identifier == "IST" {
            return "IST"
        }
        
        let isDaylightSavingTime = isDaylightSavingTime(for: selectedDate)
        
        // Europe/London should always either be BST or GMT
        if identifier == "Europe/London" {
            return isDaylightSavingTime ? "BST" : "GMT"
        }
        
        let shortStyle: TimeZone.NameStyle = isDaylightSavingTime ? .shortDaylightSaving : .shortStandard
        let longStyle: TimeZone.NameStyle = isDaylightSavingTime ? .daylightSaving : .standard
        let timeZoneStyle = usingShort ? shortStyle : longStyle
        
        // America/* time zones should use fudged versions of their localised names
        // Requested by Myke/Stephen. e.g:
        // - Pacific Standard Time -> Pacific
        // - Eastern Daylight Time -> Eastern
        // - Central Daylight Time -> CT
        // - Mountain Standard Time -> MT
        if identifier.starts(with: "America/") {
            if let localizedName = localizedName(for: timeZoneStyle, locale: Locale(identifier: "en_US")) {
                return localizedName.replacingOccurrences(of: "DT", with: "T").replacingOccurrences(of: "ST", with: "T").replacingOccurrences(of: " Daylight", with: "").replacingOccurrences(of: " Standard", with: "").replacingOccurrences(of: " Time", with: "")
            }
        }
        
        // Australia/* time zones should use their localised short names such as AEST/AEDT
        if identifier.starts(with: "Australia/") {
            if let localizedName = localizedName(for: shortStyle, locale: Locale(identifier: "en_AU")) {
                return localizedName
            }
        }
        
        guard let abbreviation = abbreviation(for: selectedDate) else { return nil }
        
        logger.debug("identifier: \(identifier) abbreviation: \(abbreviation)")
        
        // Europe/* time zones should return CET instead of their GMT offsets
        if identifier.starts(with: "Europe") {
            if abbreviation == "CET" { return abbreviation }
            if isDaylightSavingTime && abbreviation == "GMT+2" || !isDaylightSavingTime && abbreviation == "GMT+1" {
                return "CET"
            }
        }
        
        // Finally, use the time zone's localised name if there is one, otherwise the standard abbreviation
        guard let localizedName = localizedName(for: timeZoneStyle, locale: Locale.current) else { return abbreviation }
        
        return localizedName
        
    }
    
    var mykeModeTimeFormat: TimeFormat {
        if UserDefaults.shared.mykeModeTimeZoneIdentifiersUsing24HourTime.contains(self) {
            return .twentyFour
        }
        if UserDefaults.shared.mykeModeTimeZoneIdentifiersUsing12HourTime.contains(self) {
            return .twelve
        }
        return UserDefaults.shared.mykeModeDefaultTimeFormat
    }
    
}


extension Calendar {
    var currentYearAsString: String {
        let nf = NumberFormatter()
        nf.groupingSeparator = nil
        return nf.string(from: NSNumber(value: component(.year, from: Date()))) ?? "0000"
    }
}
