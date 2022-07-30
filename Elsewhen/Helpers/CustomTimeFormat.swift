//
//  CustomTimeFormat.swift
//  Elsewhen
//
//  Created by Ben Cardy on 29/07/2022.
//

import SwiftUI
import Foundation

struct CustomTimeFormat: Identifiable, Codable {
    let id: UUID
    let format: String
    let icon: String
    let red: Double
    let green: Double
    let blue: Double
    
    var color: Color {
        Color(.sRGB, red: self.red, green: self.green, blue: self.blue, opacity: 1)
    }
    
}
