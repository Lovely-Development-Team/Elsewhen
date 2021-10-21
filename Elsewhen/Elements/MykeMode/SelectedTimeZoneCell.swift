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
    let flag: String
    let timeInZone: String
    let selectedDate: Date
    
    var body: some View {
        let abbreviation = tz.fudgedAbbreviation(for: selectedDate)
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(tz.friendlyName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if let abbreviation = abbreviation {
                    Text(abbreviation)
                        .foregroundColor(.secondary)
                }
            }
            .onDrag {
                let tzItemProvider = tz.itemProvider
                let itemProvider = NSItemProvider(object: tzItemProvider)
                itemProvider.suggestedName = tzItemProvider.resolvedName
                return itemProvider
            }
            Text("\(flag) \(timeInZone)")
                .onDrag {
                    return NSItemProvider(object: timeInZone as NSString)
                }
        }
        .accessibilityElement()
        .accessibilityLabel(Text("\(tz.friendlyName): \(timeInZone), \(abbreviation ?? "")"))
    }
}
