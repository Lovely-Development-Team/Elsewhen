//
//  TimeZoneChoiceItem.swift
//  TimeZoneChoiceItem
//
//  Created by Ben Cardy on 14/09/2021.
//

import SwiftUI

struct TimeZoneChoiceItem: View {
    
    var tz: TimeZone
    var isSelected: Bool
    var abbreviation: String?
    @Binding var isFavourite: Bool
    
    @State var viewId: Int = 0
    
    var body: some View {
        HStack {
            FavouriteIndicator(isFavourite: $isFavourite)
            Text(tz.friendlyName)
            Spacer()
            if let abbreviation = abbreviation {
                Text(abbreviation)
                    .foregroundColor(.secondary)
            }
            if isSelected {
                Image(systemName: "checkmark")
            }
        }
        .foregroundColor(isSelected ? .accentColor : .primary)
        .contextMenu {
            StarUnstarButton(isStarred: $isFavourite)
        }
        .onChange(of: isFavourite, perform: { newValue in
            viewId += 1
        })
        .id(viewId)
    }
}

struct TimeZoneChoiceItem_Previews: PreviewProvider {
    static var previews: some View {
        TimeZoneChoiceItem(tz: TimeZone(identifier: "Europe/London")!, isSelected: true, abbreviation: nil, isFavourite: .constant(true))
    }
}
