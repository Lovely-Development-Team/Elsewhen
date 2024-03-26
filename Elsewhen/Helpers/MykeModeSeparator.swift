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
    
    var id: String { self.rawValue }
    
}

enum MykeModeLineSeparator: String, CaseIterable, Identifiable {
    case newLine = "\n"
    case comma = ", "
    case slash = " / "
    
    var description: String {
        switch self {
        case .newLine:
            return "New Line"
        case .comma:
            return "Comma"
        case .slash:
            return "Slash"
        }
    }
    
    var id: String { self.rawValue}
    
}
