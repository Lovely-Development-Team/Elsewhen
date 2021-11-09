//
//  Settings.swift
//  Elsewhen
//
//  Created by Ben Cardy on 06/11/2021.
//

import SwiftUI

struct Settings: View {
    
    @State private var defaultTimeZone: TimeZone? = nil
    @State private var defaultDate: Date = Date.distantPast
    
    private var defaultTimeZoneName: String {
        defaultTimeZone?.friendlyName ?? "Device"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink(destination: AltIconView()) {
                        Text("App Icon")
                    }
                    NavigationLink(destination: TimezoneChoiceView(selectedTimeZone: $defaultTimeZone, selectedTimeZones: .constant([]), selectedDate: $defaultDate, selectMultiple: false, showDeviceLocalOption: true)) {
                        HStack {
                            Text("Default Time Zone")
                            Spacer()
                            Text(defaultTimeZoneName)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                Section {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("\(AboutElsewhen.appVersion) (\(AboutElsewhen.buildNumber))")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onAppear {
                defaultTimeZone = UserDefaults.shared.resetButtonTimeZone
            }
            .onChange(of: defaultTimeZone) { newTz in
                UserDefaults.shared.resetButtonTimeZone = newTz
            }
            .navigationTitle(Text("Settings"))
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
