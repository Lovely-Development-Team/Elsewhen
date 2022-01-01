//
//  TimeListSettings.swift
//  Elsewhen
//
//  Created by David Stephens on 19/11/2021.
//

import SwiftUI

struct TimeListSettings: View {
    #if !os(macOS)
    @EnvironmentObject internal var orientationObserver: OrientationObserver
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    @Binding var defaultTimeFormat: TimeFormat
    @Binding var mykeModeSeparator: MykeModeSeparator
    @Binding var showCities: Bool
    
    @Binding var selectedView: SettingsViews?
    @State private var viewId: Int = 1
    
    var isPadAndNotSlideOver: Bool {
        DeviceType.isPad() && horizontalSizeClass != .compact
    }
    
    var exampleOutput: String {
        let tz = UserDefaults.shared.resetButtonTimeZone ?? TimeZone.current
        let formatString = stringForTimeAndFlag(in: tz, date: Date(), sourceZone: tz, separator: mykeModeSeparator, timeZonesUsingEUFlag: [], timeZonesUsingNoFlag: [], showCities: showCities, ignoringTimeFormatOverride: true)
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
            Text("Separator")
            Spacer()
            Text(mykeModeSeparator.description)
                .foregroundColor(selectedView == .mykeModeSeparator ? .white : .secondary)
                .opacity(selectedView == .mykeModeSeparator ? 0.8 : 1)
        }
    }
    
    var body: some View {
        Section(header: Text("Time List Settings"), footer: Text(exampleOutput)) {
            if isPadAndNotSlideOver {
                Button(action: { selectedView = .mykeModeDefaultTimeFormat }) {
                    defaultTimeFormatPickerLink
                }.listRowBackground(selectedView == .mykeModeDefaultTimeFormat ? Color.accentColor : Color(UIColor.systemBackground))
                    .foregroundColor(selectedView == .mykeModeDefaultTimeFormat ? .white : .primary)
                Button(action: { selectedView = .mykeModeSeparator }) {
                    separatorPickerLink
                }.listRowBackground(selectedView == .mykeModeSeparator ? Color.accentColor : Color(UIColor.systemBackground))
                    .foregroundColor(selectedView == .mykeModeSeparator ? .white : .primary)
            } else {
                NavigationLink(destination: defaultTimeFormatPicker, tag: SettingsViews.mykeModeDefaultTimeFormat, selection: $selectedView) {
                    defaultTimeFormatPickerLink
                }
                NavigationLink(destination: separatorPicker, tag: SettingsViews.mykeModeSeparator, selection: $selectedView) {
                    separatorPickerLink
                }
            }
            Toggle("Include City Names", isOn: $showCities)
        }
        .id(viewId)
        .onChange(of: defaultTimeFormat) { newValue in
            viewId += 1
        }
    }
}

struct TimeListSettings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Form {
                TimeListSettings(defaultTimeFormat: .constant(.systemLocale), mykeModeSeparator: .constant(.hyphen), showCities: .constant(true), selectedView: .constant(.mykeModeSeparator))
            }
        }.environmentObject(OrientationObserver())
    }
}
