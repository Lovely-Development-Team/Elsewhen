//
//  MykeModeSeparator.swift
//  Elsewhen
//
//  Created by Ben Cardy on 18/11/2021.
//

import Foundation

enum MykeModeSeparator: String, CaseIterable, Identifiable {
    case hyphen = " - "
    case colon = ": "
    case noSeparator = " "
    
    var description: String {
        switch self {
        case .hyphen:
            return "Hyphen"
        case .colon:
            return "Colon"
        case .noSeparator:
            return "None"
        }
    }
    
    var id: String {
        self.rawValue
    }
    
}
