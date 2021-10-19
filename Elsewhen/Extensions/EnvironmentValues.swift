//
//  EnvironmentValues.swift
//  Elsewhen
//
//  Created by David on 19/10/2021.
//

import SwiftUI

private struct IsInPopoverKey: EnvironmentKey {
  static let defaultValue = false
}

extension EnvironmentValues {
  var isInPopover: Bool {
    get { self[IsInPopoverKey.self] }
    set { self[IsInPopoverKey.self] = newValue }
  }
}
