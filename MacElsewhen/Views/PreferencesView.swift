//
//  WidgetPreferencesView.swift
//  WidgetPreferencesView
//
//  Created by David Stephens on 17/09/2021.
//

import SwiftUI

struct PreferencesView: View {
    @AppStorage(UserDefaults.Keys.showMenuBarWidgetKey) private var showWidget: Bool = false
    @AppStorage(UserDefaults.Keys.shouldTerminateAfterLastWindowClosedKey) private var shouldTerminateAfterLastWindowClosed: Bool = false
    
    @State private var defaultTimeZone: TimeZone? = nil
    @State private var defaultDate: Date = Date.distantPast
    @State private var defaultTimeFormat: TimeFormat = .systemLocale
    @AppStorage(UserDefaults.mykeModeSeparatorKey, store: UserDefaults.shared) private var mykeModeSeparator: MykeModeSeparator = .hyphen
    
    @State private var showDefaultTimezonePopover: Bool = false
    
    private var defaultTimeZoneName: String {
        defaultTimeZone?.friendlyName ?? "Device"
    }
    
    var body: some View {
        VStack {
            Toggle("Show widget in menu bar", isOn: $showWidget)
            Toggle("Terminate after last window is closed", isOn: $shouldTerminateAfterLastWindowClosed)
            Button {
                showDefaultTimezonePopover = true
            } label: {
                HStack {
                    Text("Default Time Zone")
                    Text(defaultTimeZoneName)
                        .foregroundColor(.secondary)
                }
            }
            .popover(isPresented: $showDefaultTimezonePopover, arrowEdge: .leading) {
                TimezoneChoiceView(selectedTimeZone: $defaultTimeZone, selectedTimeZones: .constant([]), selectedDate: $defaultDate, selectMultiple: false, showDeviceLocalOption: true) {
                    showDefaultTimezonePopover = false
                }
                .frame(minWidth: 300, minHeight: 300)
            }
            Divider()
            TimeListSettings(defaultTimeFormat: $defaultTimeFormat, mykeModeSeparator: $mykeModeSeparator)
        }
        
        .padding(.horizontal)
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
    }
}

struct WidgetPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
