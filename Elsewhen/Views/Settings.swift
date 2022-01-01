//
//  Settings.swift
//  Elsewhen
//
//  Created by Ben Cardy on 06/11/2021.
//

import SwiftUI

enum SettingsViews: Int {
    case altIcon
    case defaultTimeZone
    case mykeModeDefaultTimeFormat
    case mykeModeSeparator
}

struct Settings: View {
    
    #if !os(macOS)
    @EnvironmentObject internal var orientationObserver: OrientationObserver
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    
    @State private var defaultTimeZone: TimeZone? = nil
    @State private var defaultDate: Date = Date.distantPast
    @State private var defaultTimeFormat: TimeFormat = .systemLocale
    @AppStorage(UserDefaults.mykeModeSeparatorKey, store: UserDefaults.shared) private var mykeModeSeparator: MykeModeSeparator = .hyphen
    @AppStorage(UserDefaults.mykeModeShowCitiesKey, store: UserDefaults.shared) private var mykeModeShowCities: Bool = false
    
    @State private var selectedView: SettingsViews? = nil
    @State private var viewId: Int = 1
    
    private var defaultTimeZoneName: String {
        defaultTimeZone?.friendlyName ?? "Device"
    }
    
    var footer: some View {
        VStack(spacing: 2) {
            Link(destination: URL(string: "https://tildy.dev")!) {
                Text("©2021–\(BuildConstants.buildYearString) The Lovely Developers")
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.top, 5)
        .frame(maxWidth: .infinity, alignment: .center)
        .foregroundColor(.secondary)
    }
    
    var isiPadInPortrait: Bool {
        orientationObserver.currentOrientation == .portrait && DeviceType.isPad() && horizontalSizeClass == .regular
    }
    
    var appIconView: AltIconView {
        AltIconView() { viewId += 1 }
    }
    
    var appIconLink: some View {
        HStack {
            Text("App Icon")
            Spacer()
            Text(alternativeIconNameByPath[UIApplication.shared.alternateIconName] ?? "Original")
                .foregroundColor(.secondary)
        }
    }
    
    var defaultTimeZoneView: TimezoneChoiceView {
        TimezoneChoiceView(selectedTimeZone: $defaultTimeZone, selectedTimeZones: .constant([]), selectedDate: $defaultDate, selectMultiple: false, showDeviceLocalOption: true)
    }
    
    var defaultTimeZoneLink: some View {
        HStack {
            Text("Default Time Zone")
            Spacer()
            Text(defaultTimeZoneName)
                .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    var settings: some View {
        Group {
            if isiPadInPortrait {
                Section(footer: Text("Settings").font(.largeTitle).fontWeight(.bold).foregroundColor(.primary).padding(.leading, -10)) {
                    EmptyView()
                }
            }
            Section(header: Text("General Settings")) {
                if isiPadInPortrait {
                    Button(action: {
                        self.selectedView = .altIcon
                    }) {
                        appIconLink
                    }
                    .foregroundColor(.primary)
                    Button(action: {
                        self.selectedView = .defaultTimeZone
                    }) {
                        defaultTimeZoneLink
                    }
                    .foregroundColor(.primary)
                } else {
                    NavigationLink(destination: appIconView, tag: SettingsViews.altIcon, selection: $selectedView) {
                        appIconLink
                    }
                    NavigationLink(destination: defaultTimeZoneView, tag: SettingsViews.defaultTimeZone, selection: $selectedView) {
                        defaultTimeZoneLink
                    }
                }
            }
            TimeListSettings(defaultTimeFormat: $defaultTimeFormat, mykeModeSeparator: $mykeModeSeparator, showCities: $mykeModeShowCities, selectedView: $selectedView)
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
            if DeviceType.isPad() && horizontalSizeClass != .compact {
                if selectedView == nil {
                    selectedView = .altIcon
                }
            }
        }
        .onChange(of: defaultTimeZone) { newTz in
            UserDefaults.shared.resetButtonTimeZone = newTz
            viewId += 1
        }
        .onChange(of: defaultTimeFormat) { newFormat in
            UserDefaults.shared.mykeModeDefaultTimeFormat = newFormat
        }
    }
    
    var body: some View {
        if isiPadInPortrait {
            HStack(spacing: 0) {
                Form {
                    settings
                }
                    .frame(maxWidth: 325)
                Divider()
                Group {
                    switch selectedView {
                    case .altIcon:
                        appIconView
                    case .defaultTimeZone:
                        defaultTimeZoneView
                    case .mykeModeSeparator:
                        SeparatorPicker(mykeModeSeparator: $mykeModeSeparator)
                    case .mykeModeDefaultTimeFormat:
                        DefaultTimeFormatPicker(defaultTimeFormat: $defaultTimeFormat)
                    case nil:
                        Rectangle()
                            .fill(Color(UIColor.systemBackground))
                    }
                }
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
        } else {
            NavigationView {
                Form {
                    settings
                }
                .navigationTitle(Text("Settings"))
            }
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
            .environmentObject(OrientationObserver())
    }
}
