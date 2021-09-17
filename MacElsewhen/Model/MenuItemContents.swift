//
//  MenuItemContents.swift
//  MenuItemContents
//
//  Created by David Stephens on 17/09/2021.
//

import Cocoa

struct MenuItemContents {
    let sections: [MenuItemSection]
    private let allItems: [MenuItem]
    
    init(sections: [MenuItemSection]) {
        self.sections = sections
        var initialAllItems: [MenuItem] = []
        for section in sections {
            initialAllItems.append(contentsOf: section.items)
            initialAllItems.append(MenuItem(isSeparator: true))
        }
        self.allItems = initialAllItems
    }
}

extension MenuItemContents: Collection {
    typealias Index = Int
    typealias Element = MenuItem
    var startIndex: Index { return allItems.startIndex }
    var endIndex: Index { return allItems.endIndex }
    subscript(index: Index) -> Element {
        get {
            return allItems[index]
        }
    }
    // Method that returns the next index when iterating
       func index(after i: Index) -> Index {
           return allItems.index(after: i)
       }
}
