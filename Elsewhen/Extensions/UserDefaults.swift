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
    static let mykeModeTimeZoneIdentifiersUsing12HourTimeKey = "mykeModeTimeZoneIdentifiersUsing12HourTime"
    static let mykeModeTimeZoneIdentifiersUsing24HourTimeKey = "mykeModeTimeZoneIdentifiersUsing24HourTime"
    static let favouriteTimeZoneIdentifiersKey = "favouriteTimeZoneIdentifiers"
    static let resetButtonTimeZoneIdentifierKey = "resetButtonTimeZoneIdentifier"
    static let mykeModeDefaultTimeFormatKey = "mykeModeDefaultTimeFormat"
    static let mykeModeSeparatorKey = "mykeModeSeparator"
    static let mykeModeShowCitiesKey = "mykeModeShowCities"
    
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
    
    var mykeModeTimeZoneIdentifiersUsing12HourTime: Set<TimeZone> {
        get {
            guard let identifiers = array(forKey: Self.mykeModeTimeZoneIdentifiersUsing12HourTimeKey) as? [String] else { return [] }
            return Set(identifiers.compactMap { TimeZone(identifier: $0) })
        }
        set {
            set(newValue.map { $0.identifier }, forKey: Self.mykeModeTimeZoneIdentifiersUsing12HourTimeKey)
        }
    }
    
    var mykeModeTimeZoneIdentifiersUsing24HourTime: Set<TimeZone> {
        get {
            guard let identifiers = array(forKey: Self.mykeModeTimeZoneIdentifiersUsing24HourTimeKey) as? [String] else { return [] }
            return Set(identifiers.compactMap { TimeZone(identifier: $0) })
        }
        set {
            set(newValue.map { $0.identifier }, forKey: Self.mykeModeTimeZoneIdentifiersUsing24HourTimeKey)
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
    
    @objc
    var resetButtonTimeZoneString: String? {
        get {
            string(forKey: Self.resetButtonTimeZoneIdentifierKey)
        }
        set {
            set(newValue, forKey: Self.resetButtonTimeZoneIdentifierKey)
        }
    }
    
    var resetButtonTimeZone: TimeZone? {
        get {
            guard let identifier = resetButtonTimeZoneString else { return nil }
            return TimeZone(identifier: identifier) ?? nil
        }
        set {
            resetButtonTimeZoneString = newValue?.identifier
        }
    }
    
    var mykeModeDefaultTimeFormat: TimeFormat {
        get {
            TimeFormat(rawValue: string(forKey: Self.mykeModeDefaultTimeFormatKey) ?? "systemLocale") ?? .systemLocale
        }
        set {
            set(newValue.rawValue, forKey: Self.mykeModeDefaultTimeFormatKey)
        }
    }
    
    var mykeModeSeparator: MykeModeSeparator {
        get {
            MykeModeSeparator(rawValue: string(forKey: Self.mykeModeSeparatorKey) ?? MykeModeSeparator.hyphen.rawValue) ?? .hyphen
        }
        set {
            set(newValue.rawValue, forKey: Self.mykeModeSeparatorKey)
        }
    }
    
    // Type-safe access to UserDefaults shared with the extension
    static let shared = UserDefaults(suiteName: "group.uk.co.bencardy.Elsewhen")!
}
