//
//  NSEvent.swift
//  NSEvent
//
//  Created by David Stephens on 17/09/2021.
//

import Cocoa

extension NSEvent {
    var isRightClick: Bool {
        let rightClick = (self.type == .rightMouseDown)
        let controlClick = self.modifierFlags.contains(.control)
        return rightClick || controlClick
    }
    var isOtherClick: Bool {
        return self.type == .otherMouseDown
    }
}
