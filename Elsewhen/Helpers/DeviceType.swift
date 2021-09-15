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
    static func isPhone() -> Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .phone
        #else
        return false
        #endif
    }
}
