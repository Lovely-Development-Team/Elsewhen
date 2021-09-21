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
            if isFavourite {
                #if os(macOS)
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .onTapGesture(perform: onStarClicked)
                #else
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                #endif
            } else if DeviceType.isMac() {
                Image(systemName: "star")
                    .foregroundColor(.yellow)
                    .onTapGesture(perform: onStarClicked)
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
                onStarClicked()
            }) {
                Label(isFavourite ? "Unstar" : "Star", systemImage: isFavourite ? "star.slash" : "star")
            }
        }
        .id(viewId)
    }
    
    func onStarClicked() {
        isFavourite.toggle()
        viewId += 1
    }
}

struct TimeZoneChoiceItem_Previews: PreviewProvider {
    static var previews: some View {
        TimeZoneChoiceItem(tz: TimeZone(identifier: "Europe/London")!, isSelected: true, abbreviation: nil, isFavourite: .constant(true))
    }
}
