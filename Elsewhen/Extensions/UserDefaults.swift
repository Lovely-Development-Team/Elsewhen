//
//  UserDefaults.swift
//  UserDefaults
//
//  Created by Ben Cardy on 12/09/2021.
//

import Foundation

extension UserDefaults {
    
    static let mykeModeTimeZoneIdentifiersKey = "mykeModeTimeZoneIdentifiers"
    static let mykeModeTimeZoneIdentifiersUsingEUFlagKey = "mykeModeTimeZoneIdentifiersUsingEUFlag"
    static let favouriteTimeZoneIdentifiersKey = "favouriteTimeZoneIdentifiers"
    static let resetButtonTimeZoneIdentifierKey = "resetButtonTimeZoneIdentifier"
    
    var mykeModeTimeZones: [TimeZone] {
        get {
            guard let identifiers = array(forKey: Self.mykeModeTimeZoneIdentifiersKey) as? [String] else { return [] }
            return identifiers.compactMap { TimeZone(identifier: $0) }
        }
        set {
            set(newValue.map { $0.identifier }, forKey: Self.mykeModeTimeZoneIdentifiersKey)
        }
    }
    
    var mykeModeTimeZonesUsingEUFlag: Set<TimeZone> {
        get {
            guard let identifiers = array(forKey: Self.mykeModeTimeZoneIdentifiersUsingEUFlagKey) as? [String] else { return [] }
            return Set(identifiers.compactMap { TimeZone(identifier: $0) })
        }
        set {
            set(newValue.map { $0.identifier }, forKey: Self.mykeModeTimeZoneIdentifiersUsingEUFlagKey)
        }
    }
    
    var favouriteTimeZones: Set<TimeZone> {
        get {
            guard let identifiers = array(forKey: Self.favouriteTimeZoneIdentifiersKey) as? [String] else { return [] }
            return Set(identifiers.compactMap {TimeZone(identifier: $0) })
        }
        set {
            set(newValue.map { $0.identifier }, forKey: Self.favouriteTimeZoneIdentifiersKey)
        }
    }
    
    var resetButtonTimeZone: TimeZone? {
        get {
            guard let identifier = string(forKey: Self.resetButtonTimeZoneIdentifierKey) else { return nil }
            return TimeZone(identifier: identifier) ?? nil
        }
        set {
            set(newValue?.identifier, forKey: Self.resetButtonTimeZoneIdentifierKey)
        }
    }
    
    // Type-safe access to UserDefaults shared with the extension
    static let shared = UserDefaults(suiteName: "group.uk.co.bencardy.Elsewhen")!
}
