//
//  DateHelpers.swift
//  DateHelpers
//
//  Created by David on 10/09/2021.
//

import Foundation

let dateFormats: [DateFormat] = [
    DateFormat(icon: "calendar.badge.clock", name: "Full", code: .f),
    DateFormat(icon: "calendar.badge.plus", name: "Full with Day", code: .F),
    DateFormat(icon: "calendar", name: "Date only", code: .D),
    DateFormat(icon: "clock", name: "Time only", code: .t),
    DateFormat(icon: "clock.fill", name: "Time with seconds", code: .T),
    DateFormat(icon: "clock.arrow.2.circlepath", name: "Relative", code: .R),
]

func convert(date: Date, from initialTimezone: TimeZone, to targetTimezone: TimeZone) -> Date {
    let offset = TimeInterval(targetTimezone.secondsFromGMT(for: date) - initialTimezone.secondsFromGMT(for: date))
    return date.addingTimeInterval(offset)
}

func formatTimeZoneName(_ zone: String) -> String {
    zone.replacingOccurrences(of: "_", with: " ")
}
