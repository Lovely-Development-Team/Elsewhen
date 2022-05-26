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
    
    private func storeTimeZones(_ group: NewTimeZoneGroup) {
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
    
    var newTimeZoneGroups: [NewTimeZoneGroup] {
        get {
            let results = timeZoneGroupNames.map { NewTimeZoneGroup(name: $0, timeZones: retrieveTimeZones($0)) }
            logger.debug("NSUbiquitousKeyValueStore: Fetched time zone groups: \(results)")
            return results
        }
    }
    
    func newAddTimeZoneGroup(_ group: NewTimeZoneGroup) {
        logger.debug("NSUbiquitousKeyValueStore: Asked to add: \(group)")
        storeTimeZones(group)
        timeZoneGroupNames = timeZoneGroupNames + [group.name]
    }
    
    func newRemoveTimeZoneGroup(_ group: NewTimeZoneGroup) {
        logger.debug("NSUbiquitousKeyValueStore: Asked to remove: \(group)")
        timeZoneGroupNames = timeZoneGroupNames.filter { $0 != group.name }
        removeObject(forKey: makeTimeZoneGroupKey(forName: group.name))
    }
    
    func newUpdateTimeZoneGroup(_ group: NewTimeZoneGroup, with timeZones: [TimeZone]) {
        logger.debug("NSUbiquitousKeyValueStore: Asked to update \(group.name) with \(timeZones)")
        storeTimeZones(NewTimeZoneGroup(name: group.name, timeZones: timeZones))
    }
    
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
