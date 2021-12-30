//
//  SelectedTimeZoneCell.swift
//  Elsewhen
//
//  Created by David Stephens on 23/09/2021.
//

import SwiftUI
import UniformTypeIdentifiers

struct SelectedTimeZoneCell: View {
    let tz: TimeZone
    let timeInZone: String
    let selectedDate: Date
    
    let formattedString: String
    
    var body: some View {
        let abbreviation = tz.fudgedAbbreviation(for: selectedDate)
        VStack(alignment: .leading) {
            Text(tz.friendlyName)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(formattedString)
            .onDrag {
                return NSItemProvider(object: timeInZone as NSString)
            }
        }
        .onDrag {
            let tzItemProvider = tz.itemProvider
            let itemProvider = NSItemProvider(object: tzItemProvider)
            itemProvider.suggestedName = tzItemProvider.resolvedName
            return itemProvider
        }
        .accessibilityElement()
        .accessibilityLabel(Text("\(tz.friendlyName): \(timeInZone), \(abbreviation ?? "")"))
    }
}
