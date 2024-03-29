//
//  DateHelpers.swift
//  DateHelpers
//
//  Created by David on 10/09/2021.
//

import Foundation

enum TimeFormat: String, CaseIterable {
    case systemLocale
    case twelve
    case twentyFour
    
    var description: String {
        switch self {
        case .twelve:
            return "12-Hour"
        case .twentyFour:
            return "24-Hour"
        case .systemLocale:
            return "System Locale"
        }
    }
    
    static var systemLocaleTimeFormat: Self {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .short
        let result = df.string(from: Date()).lowercased()
        if result.contains("a") || result.contains("p") {
            return .twelve
        }
        return .twentyFour
    }
    
}

enum FormatCode: String {
    case f
    case F
    case D
    case d
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
    DateFormat(icon: "calendar.badge.clock", name: "Full date and time", code: .f),
    DateFormat(icon: "calendar.badge.plus", name: "Full date and time, including day", code: .F),
    DateFormat(icon: "calendar", name: "Date only", code: .D),
    DateFormat(icon: "calendar", name: "Short date", code: .d),
    DateFormat(icon: "clock", name: "Time only", code: .t),
    DateFormat(icon: "clock.fill", name: "Time only, including seconds", code: .T)
]

let relativeDateFormat = DateFormat(icon: "clock.arrow.2.circlepath", name: "Relative time", code: .R)

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
    case .d:
        dateFormatter.dateStyle = .short
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

func discordFormat(for date: Date, in timezone: TimeZone, with formatCode: FormatCode, appendRelative: Bool) -> String {
    let timeIntervalSince1970 = Int(convert(date: date, from: timezone, to: TimeZone.current).timeIntervalSince1970)
    
    let formattedString = "<t:\(timeIntervalSince1970):\(formatCode.rawValue)>"
    
    if appendRelative && formatCode != .R {
        return formattedString + " (<t:\(timeIntervalSince1970):\(relativeDateFormat.code.rawValue)>)"
    }
    return formattedString
}

func stringFor(time date: Date, in zone: TimeZone, sourceZone: TimeZone, lowercaseAMPM: Bool = false, ignoringTimeFormatOverride: Bool = false) -> String {
    let df = DateFormatter()
    df.timeZone = zone
    df.locale = Locale.current
    let timeFormat = ignoringTimeFormatOverride ? UserDefaults.shared.mykeModeDefaultTimeFormat : zone.mykeModeTimeFormat
    let pmSymbol = df.pmSymbol ?? "pm"
    let amSymbol = df.amSymbol ?? "am"
    switch timeFormat {
    case .twelve:
        df.locale = Locale(identifier: "en_US")
    case .twentyFour:
        df.locale = Locale(identifier: "en_GB")
    case .systemLocale:
        break
    }
    df.dateStyle = .none
    df.timeStyle = .short
    var result = df.string(from: convert(date: date, from: sourceZone, to: TimeZone.current))
    if timeFormat == .twelve {
        result = result.lowercased().replacingOccurrences(of: "pm", with: pmSymbol).replacingOccurrences(of: "am", with: amSymbol)
    }
    if lowercaseAMPM {
        result = result.lowercased()
    }
    return result
}

func stringForTimeAndFlag(in tz: TimeZone, date: Date, sourceZone: TimeZone, separator: MykeModeSeparator, timeZonesUsingEUFlag: Set<TimeZone>, timeZonesUsingNoFlag: Set<TimeZone>, showCities: Bool, hideFlags: Bool = false, lowercaseAMPM: Bool = false, useShortNames: Bool = false, ignoringTimeFormatOverride: Bool = false) -> String {
    var text = ""
    let abbr = tz.fudgedAbbreviation(for: date, usingShort: useShortNames) ?? ""
    var flag: String
    if hideFlags {
        flag = ""
    } else {
        if timeZonesUsingNoFlag.contains(tz) {
            flag = NoFlagTimeZoneEmoji
        } else {
            if timeZonesUsingEUFlag.contains(tz) {
                flag = "🇪🇺"
            } else {
                flag = flagForTimeZone(tz)
            }
        }
        flag = "\(flag)\(separator.rawValue)"
    }
    text += "\(flag)\(stringFor(time: date, in: tz, sourceZone: sourceZone, lowercaseAMPM: lowercaseAMPM, ignoringTimeFormatOverride: ignoringTimeFormatOverride))"
    if showCities && tz.city != abbr {
        text += " \(tz.city) (\(abbr))"
    } else {
        text += " \(abbr)"
    }
    return text
}

func stringForTimesAndFlags<TZSequence>(of date: Date, in sourceZone: TimeZone, for timezones: TZSequence, separator: MykeModeSeparator, lineSeparator: MykeModeLineSeparator, timeZonesUsingEUFlag: Set<TimeZone>, timeZonesUsingNoFlag: Set<TimeZone>, showCities: Bool, hideFlags: Bool = false, lowercaseAMPM: Bool = false, useShortNames: Bool = false, ignoringTimeFormatOverride: Bool = false) -> String where TZSequence: Collection, TZSequence.Element == TimeZone {
    var text = "\n"
    for tz in timezones {
        text = "\(text)\(stringForTimeAndFlag(in: tz, date: date, sourceZone: sourceZone, separator: separator, timeZonesUsingEUFlag: timeZonesUsingEUFlag, timeZonesUsingNoFlag: timeZonesUsingNoFlag, showCities: showCities, hideFlags: hideFlags, lowercaseAMPM: lowercaseAMPM, useShortNames: useShortNames, ignoringTimeFormatOverride: ignoringTimeFormatOverride))\(lineSeparator.rawValue)"
    }
    return String(text.dropLast(lineSeparator.rawValue.count))
}

func filter<TZSequence>(timezones: TZSequence, by searchTerm: String, onDate: Date = Date()) -> [TimeZone] where TZSequence: Collection, TZSequence.Element == TimeZone {
    let st = searchTerm.trimmingCharacters(in: .whitespaces).lowercased().replacingOccurrences(of: " ", with: "_")
    guard !st.isEmpty else {
        return Array(timezones)
    }
    return timezones.filter { $0.matches(searchTerm: st, onDate: onDate) }
}

class DateHolder: ObservableObject {
    
    static let shared: DateHolder = DateHolder()
    @Published var date: Date = Date()
    
}
