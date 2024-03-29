//
//  Settings.swift
//  Elsewhen
//
//  Created by Ben Cardy on 06/11/2021.
//

import SwiftUI
import StoreKit

enum SettingsViews: Int {
    case altIcon
    case defaultTimeZone
    case mykeModeDefaultTimeFormat
    case mykeModeSeparator
    case mykeModeLineSeparator
    case defaultTabPicker
    case importTimeZoneGroup
    case changelog
}

struct Settings: View, OrientationObserving {
    
    #if !os(macOS)
    @EnvironmentObject internal var orientationObserver: OrientationObserver
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    
    @Binding var selectedTab: Int
    
    @State private var defaultTimeZone: TimeZone? = nil
    @State private var defaultDate: Date = Date.distantPast
    @State private var defaultTimeFormat: TimeFormat = .systemLocale
    @AppStorage(UserDefaults.mykeModeSeparatorKey, store: UserDefaults.shared) private var mykeModeSeparator: MykeModeSeparator = .hyphen
    @AppStorage(UserDefaults.mykeModeLineSeparatorKey, store: UserDefaults.shared) private var mykeModeLineSeparator: MykeModeLineSeparator = .newLine
    @AppStorage(UserDefaults.mykeModeShowCitiesKey, store: UserDefaults.shared) private var mykeModeShowCities: Bool = false
    @AppStorage(UserDefaults.mykeModeHideFlagsKey, store: UserDefaults.shared) private var mykeModeHideFlags: Bool = false
    @AppStorage(UserDefaults.mykeModeLowercaseAMPMKey, store: UserDefaults.shared) private var mykeModeLowercaseAMPM: Bool = false
    @AppStorage(UserDefaults.mykeModeUseShortNamesKey, store: UserDefaults.shared) private var mykeModeUseShortNames: Bool = false
    @AppStorage(UserDefaults.defaultTabKey) private var defaultTabIndex: Int = 0
    @AppStorage(UserDefaults.useMapKitSearchKey) private var useMapKitSearch: Bool = true
    @AppStorage(UserDefaults.lastSeenVersionForSettingsKey) private var lastSeenVersionForSettings: String = ""
    
    @State private var selectedView: SettingsViews? = nil
    @State private var viewId: Int = 1
    @StateObject private var timeZoneSearchController = TimeZoneSearchController()
    
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
        .padding(.bottom)
    }
    
    var smartTimeZoneSearchExplanation: some View {
        VStack(spacing: 5) {
            Text("Smart Time Zone Search will attempt to find the geographically closest time zone for your search result, not just based on the time zone name.")
            if timeZoneSearchController.lowPowerMode && useMapKitSearch {
                Text("Smart search results will be slower while on Low Power Mode.")
                    .foregroundColor(.red)
            }
        }
    }
    
    var appIconView: AltIconView {
        AltIconView() { viewId += 1 }
    }
    
    var appIconLink: some View {
        HStack {
            Text("App Icon")
            Spacer()
            Text(alternativeIconNameByPath[UIApplication.shared.alternateIconName] ?? "Original")
                .foregroundColor(selectedView == .altIcon ? .white : .secondary)
                .opacity(selectedView == .altIcon ? 0.8 : 1)
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
                .foregroundColor(selectedView == .defaultTimeZone ? .white : .secondary)
                .opacity(selectedView == .defaultTimeZone ? 0.8 : 1)
        }
    }
    
    var defaultTabView: DefaultTabPicker {
        DefaultTabPicker(defaultTabIndex: $defaultTabIndex)
    }
    
    var defaultTabName: String {
        switch defaultTabIndex {
        case 1:
            return "Time List"
        default:
            return "Time Codes"
        }
    }
    
    var defaultTabLink: some View {
        HStack {
//            if AboutElsewhen.buildNumber != lastSeenVersionForSettings {
//                Circle().fill(.red).frame(width: 10, height: 10)
//            }
            Text("Default Tab")
            Spacer()
            Text(defaultTabName)
                .foregroundColor(selectedView == .defaultTabPicker ? .white : .secondary)
                .opacity(selectedView == .defaultTabPicker ? 0.8 : 1)
        }
    }
    
    var appVersionLink: some View {
        Text("What's New?")
    }
    
    @ViewBuilder
    var settings: some View {
        Group {
            if isPadAndNotCompact {
                Section(footer: Text("Settings").font(.largeTitle).fontWeight(.bold).foregroundColor(.primary).padding(.leading, -10)) {
                    EmptyView()
                }
            }
            
//            if AboutElsewhen.buildNumber != lastSeenVersionForSettings {
//                Section(header: HStack {
//                    Circle().fill(.red).frame(width: 10, height: 10)
//                    Text("What's New")
//                }) {
//                    Text("**Custom Formats** let you compile and store combinations of the different Time Codes to easily copy in one tap. Now you can have quick access to that one phrase you always use. Try them out with the button at the top of the Time Codes tab.")
//                        .fixedSize(horizontal: false, vertical: true)
//                }
//            }
            
            Section(header: Text("General Settings"), footer: smartTimeZoneSearchExplanation) {
                if isPadAndNotCompact {
                    Button(action: {
                        self.selectedView = .altIcon
                    }) {
                        appIconLink
                    }
                    .listRowBackground(selectedView == .altIcon ? Color.accentColor : Color(UIColor.systemBackground))
                    .foregroundColor(selectedView == .altIcon ? .white : .primary)
                    Button(action: {
                        self.selectedView = .defaultTabPicker
                    }) {
                        defaultTabLink
                    }
                    .listRowBackground(selectedView == .defaultTabPicker ? Color.accentColor : Color(UIColor.systemBackground))
                    .foregroundColor(selectedView == .defaultTabPicker ? .white : .primary)
                    Button(action: {
                        self.selectedView = .defaultTimeZone
                    }) {
                        defaultTimeZoneLink
                    }
                    .listRowBackground(selectedView == .defaultTimeZone ? Color.accentColor : Color(UIColor.systemBackground))
                    .foregroundColor(selectedView == .defaultTimeZone ? .white : .primary)
                } else {
                    NavigationLink(destination: appIconView, tag: SettingsViews.altIcon, selection: $selectedView) {
                        appIconLink
                    }
                    NavigationLink(destination: defaultTabView, tag: SettingsViews.defaultTabPicker, selection: $selectedView) {
                        defaultTabLink
                    }
                    NavigationLink(destination: defaultTimeZoneView, tag: SettingsViews.defaultTimeZone, selection: $selectedView) {
                        defaultTimeZoneLink
                    }
                }
                
                HStack {
//                    if AboutElsewhen.buildNumber != lastSeenVersionForSettings {
//                        Circle().fill(.red).frame(width: 10, height: 10)
//                    }
                    Toggle("Smart Time Zone Search", isOn: $useMapKitSearch)
                }
                
            }
            TimeListSettings(defaultTimeFormat: $defaultTimeFormat, mykeModeSeparator: $mykeModeSeparator, mykeModeLineSeparator: $mykeModeLineSeparator, showCities: $mykeModeShowCities, hideFlags: $mykeModeHideFlags, lowercaseAMPM: $mykeModeLowercaseAMPM, useShortNames: $mykeModeUseShortNames, selectedView: $selectedView)
                .id(viewId)
            
#if DEBUG
            Section {
                Button(action: {
                    UserDefaults.shared.reset()
                    UserDefaults.standard.reset()
                }) {
                    Text("Reset all settings")
                }
            }
#endif
            Section(header: Text("Feedback")) {
                Link(destination: URL(string: "mailto:elsewhen@tildy.dev")!) {
                    Text("Send Feedback")
                        .foregroundColor(.primary)
                }
                Link(destination: URL(string: "https://itunes.apple.com/app/id\(AboutElsewhen.appId)?action=write-review")!) {
                    Text("Rate Elsewhen")
                        .foregroundColor(.primary)
                }
            }
            
            Section(footer: footer) {
                HStack {
                    Text("App Version")
                    Spacer()
                    Text("\(AboutElsewhen.appVersion) (\(AboutElsewhen.buildNumber))")
                        .foregroundColor(.secondary)
                }
                if isPadAndNotCompact {
                    Button(action: {
                        self.selectedView = .changelog
                    }) {
                        appVersionLink
                    }
                    .listRowBackground(selectedView == .changelog ? Color.accentColor : Color(UIColor.systemBackground))
                    .foregroundColor(selectedView == .changelog ? .white : .primary)
                } else {
                    NavigationLink(destination: Changelog()) {
                        appVersionLink
                    }
                }
            }
        }
        .onAppear {
            defaultTimeZone = UserDefaults.shared.resetButtonTimeZone
            defaultTimeFormat = UserDefaults.shared.mykeModeDefaultTimeFormat
            if isPadAndNotCompact {
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
        if isPadAndNotCompact {
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
                    case .defaultTabPicker:
                        defaultTabView
                    case .importTimeZoneGroup:
                        ImportTimeZoneGroupView() {
                            selectedTab = 1
                        }
                    case .changelog:
                        Changelog()
                    default:
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
        Settings(selectedTab: .constant(0))
            .environmentObject(OrientationObserver())
    }
}
