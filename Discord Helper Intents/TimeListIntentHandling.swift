//
//  TimeListIntentHandling.swift
//  TimeListIntentHandling
//
//  Created by David on 08/10/2021.
//

import Foundation
import Intents

class TimeListIntentHandling: NSObject, GetTimeListIntentHandling {
    
    func provideTimeZoneGroupOptionsCollection(for intent: GetTimeListIntent, with completion: @escaping (INObjectCollection<INTimeZoneGroup>?, Error?) -> Void) {
        completion(.init(items: NSUbiquitousKeyValueStoreController.shared.timeZoneGroupNames.map { tzGroupName in
            INTimeZoneGroup(identifier: tzGroupName, display: tzGroupName)
        }), nil)
    }
    
    func resolveTimeZoneGroup(for intent: GetTimeListIntent, with completion: @escaping (INTimeZoneGroupResolutionResult) -> Void) {
        guard let timeZoneGroup = intent.timeZoneGroup else {
            completion(.needsValue())
            return
        }
        completion(.success(with: timeZoneGroup))
    }
    
    func resolveDate(for intent: GetTimeListIntent, with completion: @escaping (INDateComponentsResolutionResult) -> Void) {
        guard let date = intent.date else {
            completion(.needsValue())
            return
        }
        completion(.success(with: date))
    }
    
    func resolveTimezone(for intent: GetTimeListIntent, with completion: @escaping (INTimezoneResolutionResult) -> Void) {
        guard let timezone = intent.timezone else {
            let currentTimezone = TimeZone.current
            let inTimezone: INTimezone = INTimezone(from: currentTimezone)
            completion(.success(with: inTimezone))
            return
        }
        completion(.success(with: timezone))
    }
    
    func resolveTimezoneSource(for intent: GetTimeListIntent, with completion: @escaping (INTimeZoneSourceResolutionResult) -> Void) {
        guard intent.timezoneSource != .unknown else {
            completion(.needsValue())
            return
        }
        completion(.success(with: intent.timezoneSource))
    }
    
    func resolveChosenTimezones(for intent: GetTimeListIntent, with completion: @escaping ([INTimezoneResolutionResult]) -> Void) {
        guard let timezones = intent.chosenTimezones else {
            completion([.needsValue()])
            return
        }
        let resolvedTimezones = timezones.map { tz in
            INTimezoneResolutionResult.success(with: tz)
        }
        completion(resolvedTimezones)
    }
    
    func resolveTimezonePickerCategory(for intent: GetTimeListIntent, with completion: @escaping (INTimeZoneSourceCategoryResolutionResult) -> Void) {
        guard intent.timezonePickerCategory != .unknown else {
            completion(.needsValue())
            return
        }
        completion(.success(with: intent.timezonePickerCategory))
    }
    
    func provideTimezoneOptionsCollection(for intent: GetTimeListIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<INTimezone>?, Error?) -> Void) {
        completion(.init(items: timezoneOptions(in: intent.timezonePickerCategory, for: searchTerm)), nil)
    }
    
    func provideChosenTimezonesOptionsCollection(for intent: GetTimeListIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<INTimezone>?, Error?) -> Void) {
        completion(.init(items: timezoneOptions(in: intent.timezonePickerCategory, for: searchTerm)), nil)
    }
    
    private func timezones(for intent: GetTimeListIntent) -> [TimeZone]? {
        switch intent.timezoneSource {
        case .chosen:
            guard let chosenInTimezones = intent.chosenTimezones else {
                return nil
            }
            return chosenInTimezones.lazy.compactMap(\.identifier).compactMap { TimeZone(identifier: $0) }
        case .selected:
            return filter(timezones: UserDefaults.shared.mykeModeTimeZones, by: "")
        case .favourites:
            return filter(timezones: Array(UserDefaults.shared.favouriteTimeZones), by: "")
        case .all:
            return TimeZone.filtered(by: "")
        case .group:
            guard let timeZoneGroup = intent.timeZoneGroup else {
                return nil
            }
            guard let name = timeZoneGroup.identifier else {
                return nil
            }
            return NSUbiquitousKeyValueStoreController.shared.retrieveTimeZoneGroup(byName: name).timeZones
        default:
            return nil
        }
    }
    
    func handle(intent: GetTimeListIntent, completion: @escaping (GetTimeListIntentResponse) -> Void) {
        let userActivity = NSUserActivity(activityType: "TimeListIntent")
        userActivity.becomeCurrent()
        userActivity.title = "Time List"
        
        guard let date = intent.date?.date else {
            completion(.init(code: .noDate, userActivity: userActivity))
            return
        }
        let timezoneIdentifier = intent.timezone?.identifier
        let timezone = timezoneIdentifier.flatMap { TimeZone(identifier: $0) } ?? TimeZone.current
        
        guard let chosenTimezones = timezones(for: intent) else {
            completion(.init(code: .noChosenTimezones, userActivity: userActivity))
            return
        }
        
        
        
        let response = GetTimeListIntentResponse(code: .success, userActivity: userActivity)
        response.discordFormat = stringForTimesAndFlags(of: date, in: timezone, for: chosenTimezones, separator: UserDefaults.shared.mykeModeSeparator, lineSeparator: UserDefaults.shared.mykeModeLineSeparator, timeZonesUsingEUFlag: UserDefaults.shared.mykeModeTimeZonesUsingEUFlag, timeZonesUsingNoFlag: UserDefaults.shared.mykeModeTimeZonesUsingNoFlag, showCities: UserDefaults.shared.mykeModeShowCities, hideFlags: UserDefaults.shared.mykeModeHideFlags)
        completion(response)
    }
    
    
}
