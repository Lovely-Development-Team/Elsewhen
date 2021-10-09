//
//  ConvertTimeIntentHandling.swift
//  ConvertTimeIntentHandling
//
//  Created by David on 10/09/2021.
//

import Foundation
import Intents

class ConvertTimeIntentHandler: NSObject, ConvertTimeIntentHandling {
    func resolveDate(for intent: ConvertTimeIntent, with completion: @escaping (INDateComponentsResolutionResult) -> Void) {
        guard let date = intent.date else {
            completion(.needsValue())
            return
        }
        completion(.success(with: date))
    }
    
    
    func resolveTimezone(for intent: ConvertTimeIntent, with completion: @escaping (INTimezoneResolutionResult) -> Void) {
        guard let timezone = intent.timezone else {
            let currentTimezone = TimeZone.current
            let inTimezone: INTimezone = INTimezone(from: currentTimezone)
            completion(.success(with: inTimezone))
            return
        }
        completion(.success(with: timezone))
    }
    
    func provideTimezoneOptionsCollection(for intent: ConvertTimeIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<INTimezone>?, Error?) -> Void) {
        completion(.init(items: timezoneOptions(in: .all, for: searchTerm)), nil)
    }
    
    func handle(intent: ConvertTimeIntent, completion: @escaping (ConvertTimeIntentResponse) -> Void) {
        let userActivity = NSUserActivity(activityType: "ConvertTimeIntent")
        userActivity.becomeCurrent()
        userActivity.title = "Convert Time"
        guard let date = intent.date?.date else {
            completion(.init(code: .noDate, userActivity: userActivity))
            return
        }
        guard let formatCode = FormatCode(from: intent.formatCode) else {
            completion(.init(code: .failure, userActivity: userActivity))
            return
        }
        let timezoneIdentifier = intent.timezone?.identifier
        let timezone = timezoneIdentifier.flatMap { TimeZone(identifier: $0) } ?? TimeZone.current
        let response = ConvertTimeIntentResponse(code: .success, userActivity: userActivity)
        response.discordFormat = discordFormat(for: date, in: timezone, with: formatCode, appendRelative: false)
        response.humanFormat = format(date: date, in: timezone, with: formatCode)
        completion(response)
    }
}
