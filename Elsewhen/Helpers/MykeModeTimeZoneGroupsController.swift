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
        NSUbiquitousKeyValueStore.default.newAddTimeZoneGroup(group)
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    func removeTimeZoneGroup(_ group: NewTimeZoneGroup) {
        timeZoneGroups = timeZoneGroups.filter { $0.name != group.name }
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
    
}
