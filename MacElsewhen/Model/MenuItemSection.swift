//
//  MenuItemSection.swift
//  MenuItemSection
//
//  Created by David Stephens on 17/09/2021.
//

import Cocoa

struct MenuItemSection {
    let items: [MenuItem]
    let count: Int
    init(items: [MenuItem]) {
        self.items = items
        self.count = items.count
    }
}
