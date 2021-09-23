//
//  SelectedTimeZoneCell.swift
//  Elsewhen
//
//  Created by David Stephens on 23/09/2021.
//

import SwiftUI

struct SelectedTimeZoneCell: View {
    let tz: TimeZone
    let flag: String
    let timeInZone: String
    let selectedDate: Date
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(tz.friendlyName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(flag) \(timeInZone)")
            }
            Spacer()
            if let abbreviation = tz.fudgedAbbreviation(for: selectedDate) {
                Text(abbreviation)
                    .foregroundColor(.secondary)
            }
        }
        .contentShape(Rectangle())
        .onDrag {
            let tzItemProvider = tz.itemProvider
            let itemProvider = NSItemProvider(object: tzItemProvider)
            itemProvider.suggestedName = tzItemProvider.resolvedName
            return itemProvider
        }
        .contentShape(Rectangle())
    }
}
