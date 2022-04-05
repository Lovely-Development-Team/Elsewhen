//
//  NSUbiquitousKeyValueStore.swift
//  Elsewhen
//
//  Created by Ben Cardy on 22/03/2022.
//

import Foundation

extension NSUbiquitousKeyValueStore {
    
    static let mykeModeTimeZoneGroupsKey = "mykeModeTimeZoneGroups"
    
    var timeZoneGroups: [TimeZoneGroup] {
        get {
            guard let rawData = data(forKey: Self.mykeModeTimeZoneGroupsKey) else {
                return []
            }
            let jsonDecoder = JSONDecoder()
            do {
                return try jsonDecoder.decode([TimeZoneGroup].self, from: rawData)
            } catch {
                print("Could not decode JSON: \(error)")
                return []
            }
        }
        set {
            let jsonEncoder = JSONEncoder()
            do {
                let data = try jsonEncoder.encode(newValue)
                set(data, forKey: Self.mykeModeTimeZoneGroupsKey)
            } catch {
                print("Could not encode JSON: \(error)")
            }
        }
    }
    
    func addTimeZoneGroup(_ group: TimeZoneGroup) {
        var tzGroups = timeZoneGroups
        tzGroups.append(group)
        timeZoneGroups = tzGroups
    }
    
    func removeTimeZoneGroup(id: UUID) {
        timeZoneGroups = timeZoneGroups.filter { $0.id != id }
    }
    
    func updateTimeZoneGroup(_ tzGroup: TimeZoneGroup, with timeZones: [TimeZone]) {
        timeZoneGroups = timeZoneGroups.map { tzGroup in
            if tzGroup.id == tzGroup.id {
                return TimeZoneGroup(copy: tzGroup, with: timeZones)
            }
            return tzGroup
        }
    }
    
}
