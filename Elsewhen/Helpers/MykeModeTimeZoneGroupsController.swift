//
//  MykeModeTimeZoneGroupsController.swift
//  Elsewhen
//
//  Created by Ben Cardy on 22/03/2022.
//

import Foundation

class MykeModeTimeZoneGroupsController: ObservableObject {
    
    static let shared = MykeModeTimeZoneGroupsController()
    
    @Published var timeZoneGroupNames: [String] = []
    @Published var timeZoneGroups: [TimeZoneGroup] = []
    
    init() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(ubiquitousKeyValueStoreDidChange(_:)),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: NSUbiquitousKeyValueStore.default)
        NSUbiquitousKeyValueStore.default.synchronize()
        updateTimeZoneGroupsFromStore()
    }
    
    @objc
    func ubiquitousKeyValueStoreDidChange(_ notification: Notification) {
        updateTimeZoneGroupsFromStore()
    }
    
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
    
    func updateTimeZoneGroupsFromStore() {
        DispatchQueue.main.async {
            logger.debug("MykeModeTimeZoneGroupsController: Updating published groups from Store")
            self.timeZoneGroupNames = NSUbiquitousKeyValueStore.default.timeZoneGroupNames
            self.timeZoneGroups = NSUbiquitousKeyValueStore.default.timeZoneGroups
            logger.debug("MykeModeTimeZoneGroupsController: Updated to: \(self.timeZoneGroupNames): \(self.timeZoneGroups)")
        }
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
    
}
