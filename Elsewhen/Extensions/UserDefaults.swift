//
//  UserDefaults.swift
//  UserDefaults
//
//  Created by Ben Cardy on 12/09/2021.
//

import Foundation

extension UserDefaults {
    
    static let mykeModeTimeZoneIdentifiersKey = "mykeModeTimeZoneIdentifiers"
    
    @objc fileprivate var mykeModeTimeZoneIdentifiers: [String] {
        get { array(forKey: Self.mykeModeTimeZoneIdentifiersKey) as? [String] ?? [] }
        set { set(newValue, forKey: Self.mykeModeTimeZoneIdentifiersKey) }
    }
    
    var mykeModeTimeZones: [TimeZone] {
        get {
            guard let identifiers = array(forKey: Self.mykeModeTimeZoneIdentifiersKey) as? [String] else { return [] }
            return identifiers.compactMap { TimeZone(identifier: $0) }
        }
        set {
            set(newValue.map { $0.identifier }, forKey: Self.mykeModeTimeZoneIdentifiersKey)
        }
    }
    
}
