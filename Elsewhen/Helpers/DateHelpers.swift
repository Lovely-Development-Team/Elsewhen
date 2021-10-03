//
//  DateHelpers.swift
//  DateHelpers
//
//  Created by David on 10/09/2021.
//

import Foundation

enum FormatCode: String {
    case f
    case F
    case D
    case t
    case T
    case R
}

struct DateFormat: Identifiable, Hashable {
    let icon: String
    let name: String
    let code: FormatCode
    
    var id: String { code.rawValue }
}

let dateFormats: [DateFormat] = [
    DateFormat(icon: "calendar.badge.clock", name: "Full", code: .f),
    DateFormat(icon: "calendar.badge.plus", name: "Full with Day", code: .F),
    DateFormat(icon: "calendar", name: "Date only", code: .D),
    DateFormat(icon: "clock", name: "Time only", code: .t),
    DateFormat(icon: "clock.fill", name: "Time with seconds", code: .T)
]

let relativeDateFormat = DateFormat(icon: "clock.arrow.2.circlepath", name: "Relative", code: .R)

func convert(date: Date, from initialTimezone: TimeZone, to targetTimezone: TimeZone) -> Date {
    let offset = TimeInterval(targetTimezone.secondsFromGMT(for: date) - initialTimezone.secondsFromGMT(for: date))
    return date.addingTimeInterval(offset)
}

func format(date: Date, in timezone: TimeZone, with formatCode: FormatCode) -> String {
    let dateFormatter = DateFormatter()
    switch formatCode {
    case .f:
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
    case .F:
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short
    case .D:
        dateFormatter.dateStyle = .long
    case .t:
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
    case .T:
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .medium
    case .R:
        let relativeFormatter = RelativeDateTimeFormatter()
        let convertedNow = convert(date: Date(), from: TimeZone.current, to: timezone)
        return relativeFormatter.localizedString(for: date, relativeTo: convertedNow)
    }
    return dateFormatter.string(from: date)
}

func discordFormat(for date: Date, in timezone: String, with formatCode: FormatCode) -> String {
    var timeIntervalSince1970 = Int(date.timeIntervalSince1970)
    
    if let tz = TimeZone(identifier: timezone) {
        timeIntervalSince1970 = Int(convert(date: date, from: tz, to: TimeZone.current).timeIntervalSince1970)
    } else {
        logger.warning("\(date, privacy: .public) is not a valid timezone identifier!")
    }
    
    return "<t:\(timeIntervalSince1970):\(formatCode.rawValue)>"
}

extension TimeZone {
    
    var friendlyName: String {
        identifier.replacingOccurrences(of: "_", with: " ")
    }
    
    var identifierContinent: String {
        String(identifier.split(separator: "/")[0])
    }
    
    var identifierWithoutContinent: String {
        let parts = identifier.split(separator: "/", maxSplits: 1)
        return String(parts[parts.count > 1 ? 1 : 0])
    }
    
    var friendlyIdentifierContinent: String {
        identifierContinent.replacingOccurrences(of: "_", with: " ")
    }
    
    var friendlyIdentifierWithoutContinent: String {
        identifierWithoutContinent.replacingOccurrences(of: "_", with: " ")
    }
    
    var flag: String {
        flagForTimeZone(self)
    }
    
    var isMemberOfEuropeanUnion: Bool {
        europeanUnionTimeZones.contains(self.identifier)
    }
    
    static func filtered(by searchTerm: String) -> [TimeZone] {
        let st = searchTerm.trimmingCharacters(in: .whitespaces).lowercased().replacingOccurrences(of: " ", with: "_")
        return TimeZone.knownTimeZoneIdentifiers.compactMap { tz in
            TimeZone(identifier: tz)
        }.filter { $0.matches(searchTerm: st) }
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
