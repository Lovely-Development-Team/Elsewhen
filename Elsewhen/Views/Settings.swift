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
    @AppStorage(UserDefaults.mykeModeShowCitiesKey, store: UserDefaults.shared) private var mykeModeShowCities: Bool = false
    
    @State private var viewId: Int = 1
    
    private var defaultTimeZoneName: String {
        defaultTimeZone?.friendlyName ?? "Device"
    }
    
    var footer: some View {
        VStack(spacing: 2) {
            Link(destination: URL(string: "https://tildy.dev")!) {
                Text("©\(Calendar.current.currentYearAsString) The Lovely Developers")
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
                    NavigationLink(destination: AltIconView() { viewId += 1 }) {
                        HStack {
                            Text("App Icon")
                            Spacer()
                            Text(alternativeIconNameByPath[UIApplication.shared.alternateIconName] ?? "Original")
                                .foregroundColor(.secondary)
                        }
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
                TimeListSettings(defaultTimeFormat: $defaultTimeFormat, mykeModeSeparator: $mykeModeSeparator, showCities: $mykeModeShowCities)
                    .id(viewId)
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
                viewId += 1
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
