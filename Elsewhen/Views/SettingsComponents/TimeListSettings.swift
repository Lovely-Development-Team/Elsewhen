//
//  TimeListSettings.swift
//  Elsewhen
//
//  Created by David Stephens on 19/11/2021.
//

import SwiftUI

struct TimeListSettings: View, OrientationObserving {
    @EnvironmentObject private var timeZoneGroupController: NSUbiquitousKeyValueStoreController
    @EnvironmentObject internal var orientationObserver: OrientationObserver
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @Binding var defaultTimeFormat: TimeFormat
    @Binding var mykeModeSeparator: MykeModeSeparator
    @Binding var mykeModeLineSeparator: MykeModeLineSeparator
    @Binding var showCities: Bool
    @Binding var hideFlags: Bool
    @Binding var lowercaseAMPM: Bool
    @Binding var useShortNames: Bool
    
    @Binding var selectedView: SettingsViews?
    @State private var viewId: Int = 1
    
    @State private var showImportTimeZoneGroupSheet: Bool = false
    
    var exampleOutput: String {
        let tz = UserDefaults.shared.resetButtonTimeZone ?? TimeZone.current
        let formatString = stringForTimesAndFlags(of: Date(), in: tz, for: [TimeZone(identifier: "Europe/London")!, TimeZone(identifier: "America/New_York")!, TimeZone(identifier: "Australia/Brisbane")!], separator: mykeModeSeparator, lineSeparator: mykeModeLineSeparator, timeZonesUsingEUFlag: [], timeZonesUsingNoFlag: [], showCities: showCities, hideFlags: hideFlags, lowercaseAMPM: lowercaseAMPM, useShortNames: useShortNames, ignoringTimeFormatOverride: true).trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\n", with: "\n  ")
        return "Example:\n  \(formatString)"
    }
    
    var defaultTimeFormatPicker: DefaultTimeFormatPicker {
        DefaultTimeFormatPicker(defaultTimeFormat: $defaultTimeFormat)
    }
    
    var defaultTimeFormatPickerLink: some View {
        HStack {
            Text("Default Time Format")
                .lineLimit(1)
                .layoutPriority(2)
            Spacer()
            Text(defaultTimeFormat.description)
                .foregroundColor(selectedView == .mykeModeDefaultTimeFormat ? .white : .secondary)
                .opacity(selectedView == .mykeModeDefaultTimeFormat ? 0.8 : 1)
                .lineLimit(1)
        }
    }
    
    var separatorPicker: SeparatorPicker {
        SeparatorPicker(mykeModeSeparator: $mykeModeSeparator)
    }
    
    var separatorPickerLink: some View {
        HStack {
            Text("Flag Separator")
            Spacer()
            Text(mykeModeSeparator.description)
                .foregroundColor(selectedView == .mykeModeSeparator ? .white : .secondary)
                .opacity(selectedView == .mykeModeSeparator ? 0.8 : 1)
        }
    }
    
    var lineSeparatorPicker: LineSeparatorPicker {
        LineSeparatorPicker(mykeModeLineSeparator: $mykeModeLineSeparator)
    }
    
    var lineSeparatorPickerLink: some View {
        HStack {
            Text("Item Separator")
            Spacer()
            Text(mykeModeLineSeparator.description)
                .foregroundColor(selectedView == .mykeModeLineSeparator ? .white : .secondary)
                .opacity(selectedView == .mykeModeLineSeparator ? 0.8 : 1)
        }
    }
    
    var body: some View {
        Group {
            Section(header: Text("Time List Settings"), footer: Text(exampleOutput)) {
                if isPadAndNotCompact {
                    Button(action: { selectedView = .mykeModeDefaultTimeFormat }) {
                        defaultTimeFormatPickerLink
                    }.listRowBackground(selectedView == .mykeModeDefaultTimeFormat ? Color.accentColor : Color(UIColor.systemBackground))
                        .foregroundColor(selectedView == .mykeModeDefaultTimeFormat ? .white : .primary)
                } else {
                    NavigationLink(destination: defaultTimeFormatPicker, tag: SettingsViews.mykeModeDefaultTimeFormat, selection: $selectedView) {
                        defaultTimeFormatPickerLink
                    }
                }
                Toggle("Include City Names", isOn: $showCities)
                Toggle("Hide Country Flags", isOn: $hideFlags)
                if isPadAndNotCompact {
                    Button(action: { selectedView = .mykeModeSeparator }) {
                        separatorPickerLink
                    }.listRowBackground(selectedView == .mykeModeSeparator ? Color.accentColor : Color(UIColor.systemBackground))
                        .foregroundColor(selectedView == .mykeModeSeparator ? .white : .primary)
                        .disabled(hideFlags)
                } else {
                    NavigationLink(destination: separatorPicker, tag: SettingsViews.mykeModeSeparator, selection: $selectedView) {
                        separatorPickerLink
                    }
                    .disabled(hideFlags)
                }
                Toggle("Force Lowercase AM/PM", isOn: $lowercaseAMPM)
                Toggle("Use Short Time Zone Names", isOn: $useShortNames)
                if isPadAndNotCompact {
                    Button(action: { selectedView = .mykeModeLineSeparator }) {
                        lineSeparatorPickerLink
                    }.listRowBackground(selectedView == .mykeModeLineSeparator ? Color.accentColor : Color(UIColor.systemBackground))
                        .foregroundColor(selectedView == .mykeModeLineSeparator ? .white : .primary)
                } else {
                    NavigationLink(destination: lineSeparatorPicker, tag: SettingsViews.mykeModeLineSeparator, selection: $selectedView) {
                        lineSeparatorPickerLink
                    }
                }
            }
            
            if EWPasteboard.hasStrings() {
                Button(action: {
                    if isPadAndNotCompact {
                        selectedView = .importTimeZoneGroup
                    } else {
                        showImportTimeZoneGroupSheet = true
                    }
                }) {
                    Text("Import Time Zone Group")
                        .foregroundColor(selectedView == .importTimeZoneGroup && isPadAndNotCompact ? .white : .primary)
                }
                .listRowBackground(selectedView == .importTimeZoneGroup && isPadAndNotCompact ? Color.accentColor : Color(UIColor.systemBackground))
            }
        }
        .id(viewId)
        .onChange(of: defaultTimeFormat) { newValue in
            viewId += 1
        }
        .sheet(isPresented: $showImportTimeZoneGroupSheet) {
            NavigationView {
                ImportTimeZoneGroupView() {
                    showImportTimeZoneGroupSheet = false
                }
                    .navigationTitle("Import")
                    .inlineNavigationBarTitle()
                    .toolbar {
                        Button("Cancel") {
                            showImportTimeZoneGroupSheet = false
                        }
                    }
                    
            }
        }
    }
}

struct TimeListSettings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Form {
                TimeListSettings(defaultTimeFormat: .constant(.systemLocale), mykeModeSeparator: .constant(.hyphen), mykeModeLineSeparator: .constant(.newLine), showCities: .constant(true), hideFlags: .constant(false), lowercaseAMPM: .constant(true), useShortNames: .constant(true), selectedView: .constant(nil))
            }
        }.environmentObject(OrientationObserver())
    }
}
