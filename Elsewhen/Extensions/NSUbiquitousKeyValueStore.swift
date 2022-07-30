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
    static let customTimeCodesFormatsKey = "customTimeCodesFormats"
    
    var customTimeCodeFormats: [CustomTimeFormat] {
        get {
            guard let customTimeCodeFormats = data(forKey: Self.customTimeCodesFormatsKey) else { return [] }
            logger.debug("NSUbiquitousKeyValueStore: Fetched customTimeCodeFormats: \(customTimeCodeFormats)")
            let decoder = JSONDecoder()
            do {
                return try decoder.decode([CustomTimeFormat].self, from: customTimeCodeFormats)
            } catch {
                logger.debug("NSUbiquitousKeyValueStore: Error fetching customTimeCodeFormats: \(error)")
            }
            return []
        }
        set {
            logger.debug("NSUbiquitousKeyValueStore: Updating customTimeCodesFormats: \(newValue)")
            let encoder = JSONEncoder()
            do {
                set(try encoder.encode(newValue), forKey: Self.customTimeCodesFormatsKey)
            } catch {
                logger.debug("NSUbiquitousKeyValueStore: Error encoding customTimeCodeFormats: \(error)")
            }
        }
    }
    
    func addCustomTimeFormat(_ customFormat: CustomTimeFormat) {
        var existingFormats = customTimeCodeFormats
        existingFormats.append(customFormat)
        customTimeCodeFormats = existingFormats
    }
    
    var customTimeCodesFormats1: [String] {
        get {
            guard let customTimeCodesFormats = array(forKey: Self.customTimeCodesFormatsKey) as? [String] else { return [] }
            logger.debug("NSUbiquitousKeyValueStore: Fetched NSUbiquitousKeyValueStore: \(customTimeCodesFormats)")
            return customTimeCodesFormats
        }
        set {
            logger.debug("NSUbiquitousKeyValueStore: Updating customTimeCodesFormats: \(newValue)")
            set(newValue, forKey: Self.customTimeCodesFormatsKey)
        }
    }
    
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
