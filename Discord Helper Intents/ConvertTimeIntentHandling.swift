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
    
    func handle(intent: ConvertTimeIntent, completion: @escaping (ConvertTimeIntentResponse) -> Void) {
        guard let date = intent.date else {
            completion(.init(code: .failure, userActivity: nil))
            return
        }
        guard let inFormat = FormatCode(from: intent.formatCode) else {
            completion(.init(code: .failure, userActivity: nil))
            return
        }
        let response = ConvertTimeIntentResponse(code: .success, userActivity: nil)
        response.discordFormat = format(date: date.date!, in: .current, with: inFormat)
        completion(response)
    }
}
