//
//  TimeZone+DropDelegate.swift
//  TimeZone+DropDelegate
//
//  Created by David on 11/09/2021.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension TimeZone {
    struct TZDropDelegate: DropDelegate {
        let onDrop: ((TimeZone?) -> ())
        func performDrop(info: DropInfo) -> Bool {
            let itemProviders = info.itemProviders(for: [UTType.json, UTType.text])
            guard !itemProviders.isEmpty else {
                return false
            }
            for itemProvider in itemProviders {
                if itemProvider.canLoadObject(ofClass: TimeZone.ItemProvider.self) {
                    itemProvider.loadObject(ofClass: TimeZone.ItemProvider.self) { tzItemProvider, error in
                        guard let tzItemProvider = tzItemProvider as? TimeZone.ItemProvider,
                              error == nil else {
                                  if let error = error {
                                      logger.error("Unabled to load dropped item: \(error.localizedDescription)")
                                  }
                                  onDrop(nil)
                                  return
                              }
                        onDrop(TimeZone(identifier: tzItemProvider.identifier))
                    }
                    return true
                }
            }
            return false
        }
    }
}
