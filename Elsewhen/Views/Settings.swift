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
    @State private var defaultTimeFormat: TimeFormat = .systemLocale
    @AppStorage(UserDefaults.mykeModeSeparatorKey, store: UserDefaults.shared) private var mykeModeSeparator: MykeModeSeparator = .hyphen
    
    private var defaultTimeZoneName: String {
        defaultTimeZone?.friendlyName ?? "Device"
    }
    
    var footer: some View {
        VStack(spacing: 2) {
            Link(destination: URL(string: "https://tildy.dev")!) {
                Text("©2021 The Lovely Developers")
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.top, 5)
        .frame(maxWidth: .infinity, alignment: .center)
        .foregroundColor(.secondary)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("General Settings")) {
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
                }
                Section(footer: footer) {
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
                defaultTimeFormat = UserDefaults.shared.mykeModeDefaultTimeFormat
            }
            .onChange(of: defaultTimeZone) { newTz in
                UserDefaults.shared.resetButtonTimeZone = newTz
            }
            .onChange(of: defaultTimeFormat) { newFormat in
                UserDefaults.shared.mykeModeDefaultTimeFormat = newFormat
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
