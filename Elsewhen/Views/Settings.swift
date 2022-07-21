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
    @AppStorage(UserDefaults.mykeModeShowCitiesKey, store: UserDefaults.shared) private var mykeModeShowCities: Bool = false
    @AppStorage(UserDefaults.defaultTabKey) private var defaultTabIndex: Int = 0
    @AppStorage(UserDefaults.useMapKitSearchKey) private var useMapKitSearch: Bool = true
    @AppStorage(UserDefaults.lastSeenVersionForSettingsKey) private var lastSeenVersionForSettings: String = ""
    
    @State private var selectedView: SettingsViews? = nil
    @State private var viewId: Int = 1
    @StateObject private var timeZoneSearchController = TimeZoneSearchController()
    
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
            Text("SMART_TIME_ZONE_SEARCH_DESCRIPTION")
            if timeZoneSearchController.lowPowerMode && useMapKitSearch {
                Text("SMART_TIME_ZONE_SEARCH_LOW_POWER_WARNING")
                    .foregroundColor(.red)
            }
        }
    }
    
    var appIconView: AltIconView {
        AltIconView() { viewId += 1 }
    }
    
    var appIconLink: some View {
        HStack {
            Text("APP_ICON_TITLE")
            Spacer()
            Text(alternativeIconNameByPath[UIApplication.shared.alternateIconName] ?? "ORIGINAL")
                .foregroundColor(selectedView == .altIcon ? .white : .secondary)
                .opacity(selectedView == .altIcon ? 0.8 : 1)
        }
    }
    
    var defaultTimeZoneView: TimezoneChoiceView {
        TimezoneChoiceView(selectedTimeZone: $defaultTimeZone, selectedTimeZones: .constant([]), selectedDate: $defaultDate, selectMultiple: false, showDeviceLocalOption: true)
    }
    
    var defaultTimeZoneLink: some View {
        HStack {
            Text("DEFAULT_TIME_ZONE_TITLE")
            Spacer()
            Group {
                if let defaultTimeZone = defaultTimeZone {
                    Text(defaultTimeZone.friendlyName)
                } else {
                    Text("DEVICE")
                }
            }
                .foregroundColor(selectedView == .defaultTimeZone ? .white : .secondary)
                .opacity(selectedView == .defaultTimeZone ? 0.8 : 1)
        }
    }
    
    var defaultTabView: DefaultTabPicker {
        DefaultTabPicker(defaultTabIndex: $defaultTabIndex)
    }
    
    var defaultTabName: LocalizedStringKey {
        switch defaultTabIndex {
        case 1:
            return "TIME_LIST_LABEL"
        default:
            return "TIME_CODES_LABEL"
        }
    }
    
    var defaultTabLink: some View {
        HStack {
//            if AboutElsewhen.buildNumber != lastSeenVersionForSettings {
//                Circle().fill(.red).frame(width: 10, height: 10)
//            }
            Text("DEFAULT_TAB_TITLE")
            Spacer()
            Text(defaultTabName)
                .foregroundColor(selectedView == .defaultTabPicker ? .white : .secondary)
                .opacity(selectedView == .defaultTabPicker ? 0.8 : 1)
        }
    }
    
    var appVersionLink: some View {
        Text("WHATS_NEW_TITLE")
    }
    
    @ViewBuilder
    var settings: some View {
        Group {
            if isPadAndNotCompact {
                Section(footer: Text("SETTINGS_TITLE").font(.largeTitle).fontWeight(.bold).foregroundColor(.primary).padding(.leading, -10)) {
                    EmptyView()
                }
            }
            
//            if AboutElsewhen.buildNumber != lastSeenVersionForSettings {
//                Section(header: HStack {
//                    Circle().fill(.red).frame(width: 10, height: 10)
//                    Text("What's New")
//                }) {
//                    Text("**Time Zone Groups** let you store combinations of Time Zones for quick access in the Time List tab. You can even share them with others, and import them from elsewhere into the app with the button below.")
//                        .fixedSize(horizontal: false, vertical: true)
//                }
//            }
            
            Section(header: Text("GENERAL_SETTINGS_TITLE"), footer: smartTimeZoneSearchExplanation) {
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
                    Toggle("SMART_TIME_ZONE_SEARCH_LABEL", isOn: $useMapKitSearch)
                }
                
            }
            TimeListSettings(defaultTimeFormat: $defaultTimeFormat, mykeModeSeparator: $mykeModeSeparator, showCities: $mykeModeShowCities, selectedView: $selectedView)
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
            Section(header: Text("FEEDBACK_TITLE")) {
                Link(destination: URL(string: "mailto:elsewhen@tildy.dev")!) {
                    Text("SEND_FEEDBACK")
                        .foregroundColor(.primary)
                }
                Link(destination: URL(string: "https://itunes.apple.com/app/id\(AboutElsewhen.appId)?action=write-review")!) {
                    Text("RATE_ELSEWHEN")
                        .foregroundColor(.primary)
                }
            }
            
            Section(footer: footer) {
                HStack {
                    Text("APP_VERSION")
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
                .navigationTitle(Text("SETTINGS_TITLE"))
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
