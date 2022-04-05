//
//  TimeZoneGrouop.swift
//  Elsewhen
//
//  Created by Ben Cardy on 19/02/2022.
//

import Foundation


struct TimeZoneGroupEntry: Codable {
    let identifier: String
}


struct TimeZoneGroup: Codable {
    var id = UUID()
    let name: String
    let identifiers: [TimeZoneGroupEntry]
}


let TIME_ZONE_GROUPS = [
    TimeZoneGroup(name: "Relay", identifiers: [
        TimeZoneGroupEntry(identifier: "America/Los_Angeles"),
        TimeZoneGroupEntry(identifier: "Europe/London"),
        TimeZoneGroupEntry(identifier: "Australia/Brisbane"),
        TimeZoneGroupEntry(identifier: "Australia/Melbourne"),
    ]),
    TimeZoneGroup(name: "Book Club", identifiers: [
        TimeZoneGroupEntry(identifier: "America/Los_Angeles"),
        TimeZoneGroupEntry(identifier: "America/New_York"),
        TimeZoneGroupEntry(identifier: "Europe/London"),
        TimeZoneGroupEntry(identifier: "Europe/Budapest"),
        TimeZoneGroupEntry(identifier: "Australia/Brisbane"),
    ]),
    TimeZoneGroup(name: "Film Club", identifiers: [
        TimeZoneGroupEntry(identifier: "America/Los_Angeles"),
        TimeZoneGroupEntry(identifier: "America/Boise"),
        TimeZoneGroupEntry(identifier: "Africa/Cairo"),
        TimeZoneGroupEntry(identifier: "Europe/London"),
    ]),
    TimeZoneGroup(name: "Hawkstone", identifiers: [
        TimeZoneGroupEntry(identifier: "America/Los_Angeles"),
        TimeZoneGroupEntry(identifier: "America/New_York"),
        TimeZoneGroupEntry(identifier: "Europe/London"),
        TimeZoneGroupEntry(identifier: "Europe/Budapest"),
        TimeZoneGroupEntry(identifier: "Africa/Cairo"),
        TimeZoneGroupEntry(identifier: "Australia/Sydney"),
    ]),
    TimeZoneGroup(name: "Others", identifiers: [
        TimeZoneGroupEntry(identifier: "America/Los_Angeles"),
        TimeZoneGroupEntry(identifier: "America/New_York"),
        TimeZoneGroupEntry(identifier: "Europe/London"),
        TimeZoneGroupEntry(identifier: "Europe/Budapest"),
        TimeZoneGroupEntry(identifier: "Africa/Cairo"),
        TimeZoneGroupEntry(identifier: "Australia/Melbourne"),
        TimeZoneGroupEntry(identifier: "Australia/Sydney"),
    ]),
]
