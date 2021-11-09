//
//  SelectTimeZoneButton.swift
//  SelectTimeZoneButton
//
//  Created by David on 16/09/2021.
//

import SwiftUI

struct SelectTimeZoneButton: View {
    @Binding var selectedTimeZone: TimeZone?
    let onPress: () -> ()
    
    #if os(macOS)
    var text: some View {
        Text(selectedTimeZone.identifier.replacingOccurrences(of: "_", with: " ") ?? "Current")
            .foregroundColor(.primary)
    }
    #else
    var text: some View {
        Text(selectedTimeZone?.identifier.replacingOccurrences(of: "_", with: " ") ?? "Current")
            .foregroundColor(.primary)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.secondarySystemBackground)
            )
    }
    #endif
    
    var body: some View {
        Button(action: {
            onPress()
        }) {
            text
        }
    }
}

struct SelectTimeZoneButton_Previews: PreviewProvider {
    static var previews: some View {
        SelectTimeZoneButton(selectedTimeZone: .constant(.current), onPress: {})
    }
}
