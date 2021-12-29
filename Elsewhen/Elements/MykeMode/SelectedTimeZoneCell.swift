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
    
    let formattedString: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(tz.friendlyName)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(formattedString)
            .onDrag {
                let tzItemProvider = tz.itemProvider
                let itemProvider = NSItemProvider(object: tzItemProvider)
                itemProvider.suggestedName = tzItemProvider.resolvedName
                return itemProvider
            }
        }
    }
}
