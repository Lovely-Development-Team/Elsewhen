//
//  IntentHandler.swift
//  Discord Helper Intents
//
//  Created by David on 10/09/2021.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        switch intent {
        case is ConvertTimeIntent:
            return ConvertTimeIntentHandler()
        case is GetTimeListIntent:
            return TimeListIntentHandling()
        default:
            return self
        }
    }
    
}
