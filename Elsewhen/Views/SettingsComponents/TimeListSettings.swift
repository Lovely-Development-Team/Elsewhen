//
//  TimeListSettings.swift
//  Elsewhen
//
//  Created by David Stephens on 19/11/2021.
//

import SwiftUI

struct TimeListSettings: View {
    @Binding var defaultTimeFormat: TimeFormat
    @Binding var mykeModeSeparator: MykeModeSeparator
    @Binding var showCities: Bool
    
    var body: some View {
        Section(header: Text("Time List Settings")) {
            NavigationLink(destination: DefaultTimeFormatPicker(defaultTimeFormat: $defaultTimeFormat)) {
                HStack {
                    Text("Default Time Format")
                    Spacer()
                    Text(defaultTimeFormat.description)
                        .foregroundColor(.secondary)
                }
            }
            NavigationLink(destination: SeparatorPicker(mykeModeSeparator: $mykeModeSeparator)) {
                HStack {
                    Text("Separator")
                    Spacer()
                    Text(mykeModeSeparator.description)
                        .foregroundColor(.secondary)
                }
            }
            Toggle("Include City Names", isOn: $showCities)
        }
    }
}

struct TimeListSettings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Form {
                TimeListSettings(defaultTimeFormat: .constant(.systemLocale), mykeModeSeparator: .constant(.hyphen), showCities: .constant(true))
            }
        }
    }
}
