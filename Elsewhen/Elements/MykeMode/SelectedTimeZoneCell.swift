//
//  SelectedTimeZoneCell.swift
//  Elsewhen
//
//  Created by Ben Cardy on 19/06/2022.
//

import SwiftUI

struct SelectedTimeZoneCell: View {
    let tz: TimeZone
    let timeInZone: String
    let selectedDate: Date
    
    let formattedString: String
    
    let onTap: (_ tz: TimeZone) -> ()
    
    var groupBody: some View {
        Group {
            Text(tz.friendlyName)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            Text(formattedString)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primary)
                .font(.system(.body, design: .rounded))
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 2)
        }
    }
    
    var macOSBody: some View {
        VStack {
            groupBody
        }
    }
    
    var iOSBody: some View {
        GroupBox {
            groupBody
        }
    }
    
    var body: some View {
        let abbreviation = tz.fudgedAbbreviation(for: selectedDate)
        
        Group {
            #if os(macOS)
            macOSBody
            #else
            iOSBody
            #endif
        }
        .onDrag {
            return NSItemProvider(object: timeInZone as NSString)
        }
        .onTapGesture {
            onTap(tz)
        }
        .accessibilityElement()
        .accessibilityLabel(Text("\(tz.friendlyName): \(timeInZone), \(abbreviation ?? "")"))
    }
}

struct SelectedTimeZoneCell_Previews: PreviewProvider {
    static var previews: some View {
        SelectedTimeZoneCell(tz: TimeZone.current, timeInZone: "10:40", selectedDate: Date(), formattedString: "🇬🇧 13:41 London (BST)", onTap: { tz in })
    }
}
