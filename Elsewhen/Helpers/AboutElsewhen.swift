//
//  AboutElsewhen.swift
//  Elsewhen
//
//  Created by Ben Cardy on 07/11/2021.
//

import Foundation

public enum AboutElsewhen {
    public static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    }
    
    public static var buildNumber: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    }
    
    public static let appId: String = "1588708173"
}
