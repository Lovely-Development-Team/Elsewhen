//
//  SearchBar.swift
//  MacElsewhen
//
//  Created by David on 19/10/2021.
//

import SwiftUI
import Cocoa

struct SearchBar: NSViewRepresentable {
    typealias NSViewType = NSSearchField
    

    @Binding var text: String
    var placeholder: String

    class Coordinator: NSObject, NSSearchFieldDelegate {

        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }
        
        @objc func update(sender: NSSearchField) {
            text = sender.stringValue
            if !text.isEmpty {
                if let previousSearch = sender.recentSearches.first,
                   text.starts(with: previousSearch) {
                    // It's a lot faster to replace the entry in-place
                    sender.recentSearches[sender.recentSearches.startIndex] = text
                    return
                }
                if let existingTextIdx = sender.recentSearches.firstIndex(of: text) {
                    // Moving is O(n log n), so we prefer that to inserting
                    sender.recentSearches.move(fromOffsets: IndexSet(integer: existingTextIdx), toOffset: 0)
                    return
                }
                // Entry doesn't exist in any form, we'll insert
                sender.recentSearches.insert(text, at: 0)
            }
        }
        
        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            // Using the property on the textView because this may be called before `update` modifies our `text`
            let isSearchEmpty = textView.string.isEmpty
            if commandSelector == #selector(NSResponder.cancelOperation(_:)) && isSearchEmpty {
                control.endEditing(textView)
                return true
            }
            return false
        }
        
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }
    
    private func makeMenuItem(title: String, tag: Int) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.tag = tag
        return item
    }
    
    private func makeSearchBarMenu() -> NSMenu {
        let menu = NSMenu()
        let recentsTitleItem = makeMenuItem(title: "Recent Searches", tag: NSSearchField.recentsTitleMenuItemTag)
        let recentsItem = makeMenuItem(title: "Recents", tag: NSSearchField.recentsMenuItemTag)
        let noRecentsItem = makeMenuItem(title: "No Recent Searches", tag: NSSearchField.noRecentsMenuItemTag)
        let separator = NSMenuItem.separator()
        separator.tag = NSSearchField.recentsTitleMenuItemTag
        let clearItem = makeMenuItem(title: "Clear Recents", tag: NSSearchField.clearRecentsMenuItemTag)
        menu.insertItem(recentsTitleItem, at: 0)
        menu.insertItem(recentsItem, at: 1)
        menu.insertItem(noRecentsItem, at: 2)
        menu.insertItem(separator, at: 3)
        menu.insertItem(clearItem, at: 4)
        return menu
    }

    func makeNSView(context: NSViewRepresentableContext<SearchBar>) -> NSSearchField {
        let searchBar = NSSearchField()
        searchBar.delegate = context.coordinator
        searchBar.placeholderString = placeholder
        searchBar.searchMenuTemplate = makeSearchBarMenu()
        searchBar.sendsSearchStringImmediately = false
        searchBar.target = context.coordinator
        searchBar.action = #selector(Self.Coordinator.update(sender:))
        return searchBar
    }

    func updateNSView(_ uiView: NSSearchField, context: NSViewRepresentableContext<SearchBar>) {
        uiView.stringValue = text
    }
    
}
