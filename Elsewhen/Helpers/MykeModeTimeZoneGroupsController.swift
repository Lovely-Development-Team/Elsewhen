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
    @Published var timeZoneGroups: [NewTimeZoneGroup] = []
    
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
    
    func addTimeZoneGroup(_ group: NewTimeZoneGroup) {
        timeZoneGroups.append(group)
        timeZoneGroupNames = timeZoneGroups.map { $0.name }
        NSUbiquitousKeyValueStore.default.newAddTimeZoneGroup(group)
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    func removeTimeZoneGroup(_ group: NewTimeZoneGroup) {
        timeZoneGroups = timeZoneGroups.filter { $0.name != group.name }
        timeZoneGroupNames = timeZoneGroups.map { $0.name }
        NSUbiquitousKeyValueStore.default.newRemoveTimeZoneGroup(group)
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    func updateTimeZoneGroup(_ tzGroup: NewTimeZoneGroup, with timeZones: [TimeZone]) {
        NSUbiquitousKeyValueStore.default.newUpdateTimeZoneGroup(tzGroup, with: timeZones)
        updateTimeZoneGroupsFromStore()
    }
    
    func updateTimeZoneGroupsFromStore() {
        timeZoneGroupNames = NSUbiquitousKeyValueStore.default.timeZoneGroupNames
        timeZoneGroups = NSUbiquitousKeyValueStore.default.newTimeZoneGroups
    }
    
    func retrieveTimeZoneGroup(byName name: String) -> NewTimeZoneGroup {
        return NewTimeZoneGroup(name: name, timeZones: NSUbiquitousKeyValueStore.default.retrieveTimeZones(name))
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
    
    func parseTimeZoneGroupDetails(_ groupDetails: String) -> NewTimeZoneGroup? {
        let lines = groupDetails.trimmingCharacters(in: .whitespacesAndNewlines).split(whereSeparator: \.isNewline)
        guard let groupName = lines.first else { return nil }
        let timeZones = lines.dropFirst().compactMap { TimeZone(identifier: String($0).trimmingCharacters(in: .whitespacesAndNewlines)) }
        return NewTimeZoneGroup(name: String(groupName), timeZones: timeZones)
    }
    
}
