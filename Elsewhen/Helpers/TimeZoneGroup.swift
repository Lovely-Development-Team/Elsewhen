//
//  TimeZoneGrouop.swift
//  Elsewhen
//
//  Created by Ben Cardy on 19/02/2022.
//

import Foundation

struct TimeZoneGroup: Equatable, CustomStringConvertible {
    
    let name: String
    let timeZones: [TimeZone]
    
    static func == (lhs: TimeZoneGroup, rhs: TimeZoneGroup) -> Bool {
        lhs.name == rhs.name
    }
    
    var exportText: String {
        var exportData = [name]
        exportData += timeZones.map { $0.identifier }
        return exportData.joined(separator: "\n")
    }
    
    var description: String {
        "\(name): \(timeZones)"
    }
    
}
