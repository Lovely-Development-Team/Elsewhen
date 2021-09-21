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
    
    @ViewBuilder
    var content: some View {
        #if os(macOS)
        TimeZoneChoiceItem(tz: tz, isSelected: isSelected, abbreviation: abbreviation, isFavourite: $isFavourite)
            .contentShape(Rectangle())
            .onTapGesture {
                onSelect(tz)
            }.contextMenu {
                Button(action: {
                    isFavourite.toggle()
                }) {
                    Label(isFavourite ? "Unstar" : "Star", systemImage: isFavourite ? "star.slash" : "star")
                }
            }
        Divider()
        #else
        Button(action: {
            onSelect(tz)
        }) {
            TimeZoneChoiceItem(tz: tz, isSelected: isSelected, abbreviation: abbreviation, isFavourite: $isFavourite)
        }
        #endif
    }
    
    var body: some View {
        if #available(iOS 15.0, macOS 12.0, *) {
            content
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button{
                        isFavourite.toggle()
                    } label: {
                        Label(isFavourite ? "Unstar" : "Star", systemImage: isFavourite ? "star.slash" : "star.fill")
                    }
                    .tint(isFavourite ? nil : .yellow)
                }
        } else {
            content
        }
    }
}

//struct TimeZoneChoiceCell_Previews: PreviewProvider {
//    static var previews: some View {
//        TimeZoneChoiceCell()
//    }
//}
