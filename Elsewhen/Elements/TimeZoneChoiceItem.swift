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
    @Binding var favouriteTimeZones: Set<TimeZone>
    
    @State var viewId: Int = 0
    
    var body: some View {
        let isFavourite = favouriteTimeZones.contains(tz)
        HStack {
            if isFavourite {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .onTapGesture(perform: { onFavourite(isFavourite) })
            } else if DeviceType.isMac() {
                Image(systemName: "star")
                    .foregroundColor(.yellow)
                    .onTapGesture(perform: { onFavourite(isFavourite) })
            }
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
            Button(action: {
                onFavourite(isFavourite)
            }) {
                Label(isFavourite ? "Unstar" : "Star", systemImage: isFavourite ? "star.slash" : "star")
            }
        }
        .id(viewId)
    }
    
    func onFavourite(_ isFavourite: Bool) {
        if isFavourite {
            favouriteTimeZones.remove(tz)
        } else {
            favouriteTimeZones.insert(tz)
        }
        viewId += 1
    }
}

struct TimeZoneChoiceItem_Previews: PreviewProvider {
    static var previews: some View {
        TimeZoneChoiceItem(tz: TimeZone(identifier: "Europe/London")!, isSelected: true, abbreviation: nil, favouriteTimeZones: .constant([TimeZone(identifier: "Europe/London")!]))
    }
}
