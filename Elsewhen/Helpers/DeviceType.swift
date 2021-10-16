//
//  DeviceType.swift
//  DeviceType
//
//  Created by David on 15/09/2021.
//

import Foundation
#if os(iOS)
import UIKit
#endif

enum DeviceType {
    
    @inlinable
    static func isPhone() -> Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .phone
        #else
        return false
        #endif
    }
    
    @inlinable
    public static func isPad() -> Bool {
        #if os(iOS)
        return UIDevice().userInterfaceIdiom == .pad
        #else
        return false
        #endif
    }
    
    @inlinable
    static func isMac() -> Bool {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }
}
