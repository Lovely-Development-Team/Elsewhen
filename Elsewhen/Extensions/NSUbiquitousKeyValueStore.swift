//
//  NSUbiquitousKeyValueStore.swift
//  Elsewhen
//
//  Created by Ben Cardy on 22/03/2022.
//

import Foundation

extension NSUbiquitousKeyValueStore {
    
    static let mykeModeTimeZoneGroupsKey = "mykeModeTimeZoneGroups"
    
    static let mykeModeTimeZoneGroupNamesKey = "mykeModeTimeZoneGroupNames"
    
    var timeZoneGroupNames: [String] {
        get {
            guard let names = array(forKey: Self.mykeModeTimeZoneGroupNamesKey) as? [String] else { return [] }
            logger.debug("NSUbiquitousKeyValueStore: Fetched timeZoneGroupNames: \(names)")
            return names
        }
        set {
            logger.debug("NSUbiquitousKeyValueStore: Updating timeZoneGroupNames: \(newValue)")
            set(newValue, forKey: Self.mykeModeTimeZoneGroupNamesKey)
        }
    }
    
    private func makeTimeZoneGroupKey(forName name: String) -> String {
        return "mykeModeTimeZoneGroup:\(name)"
    }
    
    private func storeTimeZones(_ group: TimeZoneGroup) {
        let timeZoneIdentifiers = group.timeZones.map { $0.identifier }
        let key = makeTimeZoneGroupKey(forName: group.name)
        logger.debug("NSUbiquitousKeyValueStore: Storing time zones for group \(group.name): \(key)=\(timeZoneIdentifiers)")
        set(timeZoneIdentifiers, forKey: key)
    }
    
    func retrieveTimeZones(_ groupName: String) -> [TimeZone] {
        guard let identifiers = array(forKey: makeTimeZoneGroupKey(forName: groupName)) as? [String] else { return [] }
        logger.debug("NSUbiquitousKeyValueStore: Fetched time zones for group \(groupName): \(identifiers)")
        return identifiers.compactMap { TimeZone(identifier: $0) }
    }
    
    var timeZoneGroups: [TimeZoneGroup] {
        get {
            let results = timeZoneGroupNames.map { TimeZoneGroup(name: $0, timeZones: retrieveTimeZones($0)) }
            logger.debug("NSUbiquitousKeyValueStore: Fetched time zone groups: \(results)")
            return results
        }
    }
    
    func addTimeZoneGroup(_ group: TimeZoneGroup) {
        logger.debug("NSUbiquitousKeyValueStore: Asked to add: \(group)")
        storeTimeZones(group)
        timeZoneGroupNames = timeZoneGroupNames + [group.name]
    }
    
    func removeTimeZoneGroup(_ group: TimeZoneGroup) {
        logger.debug("NSUbiquitousKeyValueStore: Asked to remove: \(group)")
        timeZoneGroupNames = timeZoneGroupNames.filter { $0 != group.name }
        removeObject(forKey: makeTimeZoneGroupKey(forName: group.name))
    }
    
    func updateTimeZoneGroup(_ group: TimeZoneGroup, with timeZones: [TimeZone]) {
        logger.debug("NSUbiquitousKeyValueStore: Asked to update \(group.name) with \(timeZones)")
        storeTimeZones(TimeZoneGroup(name: group.name, timeZones: timeZones))
    }
    
}
