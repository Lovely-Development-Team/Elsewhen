//
//  MykeModeTimeZoneGroupsController.swift
//  Elsewhen
//
//  Created by Ben Cardy on 22/03/2022.
//

import Foundation

class MykeModeTimeZoneGroupsController: ObservableObject {
    
    static let shared = MykeModeTimeZoneGroupsController()
    
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
        NSUbiquitousKeyValueStore.default.addTimeZoneGroup(group)
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    func removeTimeZoneGroup(id: UUID) {
        timeZoneGroups = timeZoneGroups.filter { $0.id != id }
        NSUbiquitousKeyValueStore.default.removeTimeZoneGroup(id: id)
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    func updateTimeZoneGroup(_ tzGroup: TimeZoneGroup, with timeZones: [TimeZone]) {
        NSUbiquitousKeyValueStore.default.updateTimeZoneGroup(tzGroup, with: timeZones)
        updateTimeZoneGroupsFromStore()
    }
    
    func updateTimeZoneGroupsFromStore() {
        timeZoneGroups = NSUbiquitousKeyValueStore.default.timeZoneGroups
    }
    
}
