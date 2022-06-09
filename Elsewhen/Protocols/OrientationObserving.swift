//
//  OrientationObserving.swift
//  Elsewhen
//
//  Created by David on 16/10/2021.
//

import Foundation
import SwiftUI

protocol OrientationObserving {
    #if !os(macOS)
    var orientationObserver: OrientationObserver { get }
    var horizontalSizeClass: UserInterfaceSizeClass? { get }
    #endif
}

extension OrientationObserving {
    var isRegularHorizontalSize: Bool {
        #if !os(macOS)
        horizontalSizeClass == .regular
        #else
        true
        #endif
    }
    
    var isCompactHorizontalSize: Bool {
        #if !os(macOS)
        horizontalSizeClass == .compact
        #else
        false
        #endif
    }
    
    var isOrientationLandscape: Bool {
        #if !os(macOS)
        orientationObserver.currentOrientation == .landscape
        #else
        true
        #endif
    }
    var isOrientationPortrait: Bool {
        #if !os(macOS)
        orientationObserver.currentOrientation == .portrait
        #else
        false
        #endif
    }
    
    var isPadAndNotCompact: Bool {
        #if !os(macOS)
        DeviceType.isPad() && horizontalSizeClass != .compact
        #else
        false
        #endif
    }
}
