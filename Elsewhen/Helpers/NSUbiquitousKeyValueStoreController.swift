//
//  NSUbiquitousKeyValueStoreController.swift
//  Elsewhen
//
//  Created by Ben Cardy on 22/03/2022.
//

import Foundation

class NSUbiquitousKeyValueStoreController: ObservableObject {
    
    static let shared = NSUbiquitousKeyValueStoreController()
    
    @Published var timeZoneGroupNames: [String] = []
    @Published var timeZoneGroups: [TimeZoneGroup] = []
    
    @Published var customTimeFormats: [CustomTimeFormat] = []
    
    init() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(ubiquitousKeyValueStoreDidChange(_:)),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: NSUbiquitousKeyValueStore.default)
        NSUbiquitousKeyValueStore.default.synchronize()
        updateFromStore()
    }
    
    @objc
    func ubiquitousKeyValueStoreDidChange(_ notification: Notification) {
        updateFromStore()
    }
    
    func updateFromStore() {
        updateTimeZoneGroupsFromStore()
        updateCustomTimeFormatsFromStore()
    }
    
    func updateTimeZoneGroupsFromStore() {
        DispatchQueue.main.async {
            logger.debug("NSUbiquitousKeyValueStoreController: Updating published groups from Store")
            self.timeZoneGroupNames = NSUbiquitousKeyValueStore.default.timeZoneGroupNames
            self.timeZoneGroups = NSUbiquitousKeyValueStore.default.timeZoneGroups
            logger.debug("NSUbiquitousKeyValueStoreController: Updated to: \(self.timeZoneGroupNames): \(self.timeZoneGroups)")
        }
    }
    
    func updateCustomTimeFormatsFromStore() {
        DispatchQueue.main.async {
            logger.debug("NSUbiquitousKeyValueStoreController: Updating published custom time formats from Store")
            self.customTimeFormats = NSUbiquitousKeyValueStore.default.customTimeCodeFormats
            logger.debug("NSUbiquitousKeyValueStoreController: Updated to: \(self.customTimeFormats)")
        }
    }
    
    // Time Zone Groups
    
    func addTimeZoneGroup(_ group: TimeZoneGroup) {
        timeZoneGroups.append(group)
        timeZoneGroupNames = timeZoneGroups.map { $0.name }
        NSUbiquitousKeyValueStore.default.addTimeZoneGroup(group)
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    func removeTimeZoneGroup(_ group: TimeZoneGroup) {
        timeZoneGroups = timeZoneGroups.filter { $0.name != group.name }
        timeZoneGroupNames = timeZoneGroups.map { $0.name }
        NSUbiquitousKeyValueStore.default.removeTimeZoneGroup(group)
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    func updateTimeZoneGroup(_ tzGroup: TimeZoneGroup, with timeZones: [TimeZone]) -> TimeZoneGroup {
        NSUbiquitousKeyValueStore.default.updateTimeZoneGroup(tzGroup, with: timeZones)
        updateTimeZoneGroupsFromStore()
        return retrieveTimeZoneGroup(byName: tzGroup.name)
    }
    
    
    func retrieveTimeZoneGroup(byName name: String) -> TimeZoneGroup {
        return TimeZoneGroup(name: name, timeZones: NSUbiquitousKeyValueStore.default.retrieveTimeZones(name))
    }
    
    func importTimeZoneGroup(fromString groupDetails: String) -> Bool {
        let newGroup = parseTimeZoneGroupDetails(groupDetails)
        if let newGroup = newGroup {
            if timeZoneGroupNames.contains(newGroup.name) {
                return false
            } else {
                addTimeZoneGroup(newGroup)
                return true
            }
        } else {
            return false
        }
    }
    
    func parseTimeZoneGroupDetails(_ groupDetails: String) -> TimeZoneGroup? {
        let lines = groupDetails.trimmingCharacters(in: .whitespacesAndNewlines).split(whereSeparator: \.isNewline)
        guard let groupName = lines.first else { return nil }
        let timeZones = lines.dropFirst().compactMap { TimeZone(identifier: String($0).trimmingCharacters(in: .whitespacesAndNewlines)) }
        return TimeZoneGroup(name: String(groupName), timeZones: timeZones)
    }
    
    // Custom Time Code Formats
    
    func addCustomTimeFormat(_ newCustomFormatString: String, icon: String = "star", red: Double = 0.427, green: Double = 0.463, blue: Double = 0.961) {
        let customTimeFormat = CustomTimeFormat(id: UUID(), format: newCustomFormatString, icon: icon, red: red, green: green, blue: blue)
        customTimeFormats.append(customTimeFormat)
        NSUbiquitousKeyValueStore.default.addCustomTimeFormat(customTimeFormat)
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    func removeCustomTimeFormat(_ customFormat: CustomTimeFormat) {
        customTimeFormats = customTimeFormats.filter { $0.id != customFormat.id }
        
        NSUbiquitousKeyValueStore.default.customTimeCodeFormats = customTimeFormats
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
}
