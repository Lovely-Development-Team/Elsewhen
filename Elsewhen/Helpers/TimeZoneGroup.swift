//
//  TimeZoneGrouop.swift
//  Elsewhen
//
//  Created by Ben Cardy on 19/02/2022.
//

import Foundation

struct TimeZoneGroup: Codable, Equatable {
    var id = UUID()
    let name: String
    let identifiers: [String]
    
    static func == (lhs: TimeZoneGroup, rhs: TimeZoneGroup) -> Bool {
        lhs.id == rhs.id
    }
    
    var timeZones: [TimeZone] {
        identifiers.compactMap { TimeZone(identifier: $0) }
    }
    
    init(name: String, timeZones: [TimeZone]) {
        self.name = name
        self.identifiers = timeZones.map { $0.identifier }
    }
    
    init(copy: TimeZoneGroup, with timeZones: [TimeZone]) {
        self.id = copy.id
        self.name = copy.name
        self.identifiers = timeZones.map { $0.identifier }
    }
    
}

struct NewTimeZoneGroup: Equatable {
    let name: String
    let timeZones: [TimeZone]
    
    static func == (lhs: NewTimeZoneGroup, rhs: NewTimeZoneGroup) -> Bool {
        lhs.name == rhs.name
    }
    
}
