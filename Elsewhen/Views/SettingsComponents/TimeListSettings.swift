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
    
    var body: some View {
        Section(header: Text("Time List Settings")) {
            Picker("Default Time Format", selection: $defaultTimeFormat) {
                Text("System Locale").tag(TimeFormat.systemLocale)
                Text("12-Hour").tag(TimeFormat.twelve)
                Text("24-Hour").tag(TimeFormat.twentyFour)
            }
            Picker("Separator", selection: $mykeModeSeparator) {
                ForEach(MykeModeSeparator.allCases, id: \.self) { sep in
                    Text(sep.description).tag(sep)
                }
            }
#if os(macOS)
            // Hackily make the radio buttons line up
            .offset(CGSize(width: 12, height: 0))
#endif
        }
#if os(macOS)
        .pickerStyle(.radioGroup)
#endif
    }
}

struct TimeListSettings_Previews: PreviewProvider {
    static var previews: some View {
        TimeListSettings(defaultTimeFormat: .constant(.systemLocale), mykeModeSeparator: .constant(.hyphen))
    }
}
