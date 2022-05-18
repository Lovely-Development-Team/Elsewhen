//
//  TimeZoneChoiceCell.swift
//  TimeZoneChoiceCell
//
//  Created by David on 21/09/2021.
//

import SwiftUI

struct TimeZoneChoiceCell: View {
    let tz: TimeZone
    let isSelected: Bool
    let abbreviation: String?
    @Binding var isFavourite: Bool
    let onSelect: (TimeZone) -> ()
    var isFromLocationSearch: Bool = false
    var isButton: Bool = true
    
    @ViewBuilder
    var content: some View {
        #if os(macOS)
        TimeZoneChoiceItem(tz: tz, isSelected: isSelected, abbreviation: abbreviation, isFavourite: $isFavourite, isFromLocationSearch: isFromLocationSearch)
            .contentShape(Rectangle())
            .onTapGesture {
                onSelect(tz)
            }.contextMenu {
                StarUnstarButton(isStarred: $isFavourite.animation())
            }
        Divider()
        #else
        if isButton {
            Button(action: {
                onSelect(tz)
            }) {
                TimeZoneChoiceItem(tz: tz, isSelected: isSelected, abbreviation: abbreviation, isFavourite: $isFavourite, isFromLocationSearch: isFromLocationSearch)
            }
        } else {
            TimeZoneChoiceItem(tz: tz, isSelected: isSelected, abbreviation: abbreviation, isFavourite: $isFavourite, isFromLocationSearch: isFromLocationSearch)
        }
        #endif
    }
    
    var body: some View {
        #if os(iOS)
        if #available(iOS 15.0, *) {
            content
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    StarUnstarButton(isStarred: $isFavourite.animation())
                }
        } else {
            content
        }
        #else
        content
        #endif
    }
}

//struct TimeZoneChoiceCell_Previews: PreviewProvider {
//    static var previews: some View {
//        TimeZoneChoiceCell()
//    }
//}
