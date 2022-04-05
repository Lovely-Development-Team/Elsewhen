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
        let result = NSUbiquitousKeyValueStore.default.synchronize()
        print("BEN: sync result 1: \(result)")
        updateTimeZoneGroupsFromStore()
    }
    
    @objc
    func ubiquitousKeyValueStoreDidChange(_ notification: Notification) {
        updateTimeZoneGroupsFromStore()
    }
    
    func addTimeZoneGroup(_ group: TimeZoneGroup) {
        timeZoneGroups.append(group)
        NSUbiquitousKeyValueStore.default.addTimeZoneGroup(group)
        let result = NSUbiquitousKeyValueStore.default.synchronize()
        print("BEN: sync result 2: \(result)")
    }
    
    func removeTimeZoneGroup(id: UUID) {
        timeZoneGroups = timeZoneGroups.filter { $0.id != id }
        NSUbiquitousKeyValueStore.default.removeTimeZoneGroup(id: id)
        let result = NSUbiquitousKeyValueStore.default.synchronize()
        print("BEN: sync result 3: \(result)")
    }
    
    func updateTimeZoneGroupsFromStore() {
        timeZoneGroups = NSUbiquitousKeyValueStore.default.timeZoneGroups
        print("BEN: Updated time zone groups: \(timeZoneGroups)")
    }
    
}
