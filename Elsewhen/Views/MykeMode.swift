//
//  MykeMode.swift
//  MykeMode
//
//  Created by Ben Cardy on 11/09/2021.
//

import SwiftUI
import UniformTypeIdentifiers

struct MykeMode: View, OrientationObserving {
    
    #if !os(macOS)
    @EnvironmentObject internal var orientationObserver: OrientationObserver
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    @Environment(\.isInPopover) private var isInPopover
    
    @State private var selectedDate = Date()
    @State private var selectedTimeZone: TimeZone? = nil
    
    @State private var selectedFormatStyle: DateFormat = dateFormats[0]
    
    @State private var selectedTimeZones: [TimeZone] = []
    @State private var timeZonesUsingEUFlag: Set<TimeZone> = []
    @State private var timeZonesUsing24HourTime: Set<TimeZone> = []
    @State private var timeZonesUsing12HourTime: Set<TimeZone> = []
    
    @AppStorage(UserDefaults.mykeModeDefaultTimeFormatKey, store: UserDefaults.shared) private var defaultTimeFormat: TimeFormat = .systemLocale
    @AppStorage(UserDefaults.mykeModeSeparatorKey, store: UserDefaults.shared) private var mykeModeSeparator: MykeModeSeparator = .hyphen
    
    @State private var showCopied: Bool = false
    
    #if os(iOS)
    let mediumImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    #endif
    
    @State private var showTimeZoneSheet: Bool = false
    @State private var showTimeZonePopover: Bool = false
    @State private var selectionViewMaxHeight: CGFloat?
    
    func generateTimesAndFlagsText() -> String {
        stringForTimesAndFlags(of: selectedDate, in: selectedTimeZone ?? TimeZone.current, for: selectedTimeZones, separator: mykeModeSeparator, timeZonesUsingEUFlag: timeZonesUsingEUFlag)
    }
    
    func flagForTimeZone(_ tz: TimeZone) -> String {
        if timeZonesUsingEUFlag.contains(tz) {
            return "🇪🇺"
        }
        return tz.flag
    }
    
    func localeForTimeZone(_ tz: TimeZone) -> Locale? {
        if timeZonesUsing24HourTime.contains(tz) {
            return Locale(identifier: "en_GB")
        }
        if timeZonesUsing12HourTime.contains(tz) {
            return Locale(identifier: "en_US")
        }
        switch defaultTimeFormat {
        case .twelve:
            return Locale(identifier: "en_US")
        case .twentyFour:
            return Locale(identifier: "en_GB")
        default:
            return nil
        }
    }
    
    func stringForSelectedTime(in zone: TimeZone) -> String {
        stringFor(time: selectedDate, in: zone, sourceZone: selectedTimeZone ?? TimeZone.current, locale: localeForTimeZone(zone))
    }
    
    #if os(iOS)
    static let navigationViewStyle = StackNavigationViewStyle()
    #else
    static let navigationViewStyle = DefaultNavigationViewStyle()
    #endif
    
    @ViewBuilder
    var timeZoneList: some View {
        
        List {
            ForEach(selectedTimeZones, id: \.identifier) { tz in
                SelectedTimeZoneCell(tz: tz, flag: flagForTimeZone(tz), timeInZone: stringForSelectedTime(in: tz), selectedDate: selectedDate)
                    .onTapGesture {
                        if tz.isMemberOfEuropeanUnion {
                            #if os(iOS)
                            mediumImpactFeedbackGenerator.impactOccurred()
                            #endif
                            if timeZonesUsingEUFlag.contains(tz) {
                                timeZonesUsingEUFlag.remove(tz)
                            } else {
                                timeZonesUsingEUFlag.insert(tz)
                            }
                        }
                    }
                    .contextMenu {
                        if tz.isMemberOfEuropeanUnion {
                            Button(action: {
                                #if os(iOS)
                                mediumImpactFeedbackGenerator.impactOccurred()
                                #endif
                                if timeZonesUsingEUFlag.contains(tz) {
                                    timeZonesUsingEUFlag.remove(tz)
                                } else {
                                    timeZonesUsingEUFlag.insert(tz)
                                }
                            }) {
                                Text("Toggle EU Flag")
                            }
                        }
                        Button(action: {
                            #if os(iOS)
                            mediumImpactFeedbackGenerator.impactOccurred()
                            #endif
                            self.timeZonesUsing24HourTime.remove(tz)
                            self.timeZonesUsing12HourTime.insert(tz)
                        }) {
                            Text("12-Hour Time Format")
                        }
                        Button(action: {
                            #if os(iOS)
                            mediumImpactFeedbackGenerator.impactOccurred()
                            #endif
                            self.timeZonesUsing12HourTime.remove(tz)
                            self.timeZonesUsing24HourTime.insert(tz)
                        }) {
                            Text("24-Hour Time Format")
                        }
                        Button(action: {
                            #if os(iOS)
                            mediumImpactFeedbackGenerator.impactOccurred()
                            #endif
                            self.timeZonesUsing12HourTime.remove(tz)
                            self.timeZonesUsing24HourTime.remove(tz)
                        }) {
                            Text("Default Time Format")
                        }
                        DeleteButton {
                            #if os(iOS)
                            notificationFeedbackGenerator.prepare()
                            #endif
                            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(600))) {
                                withAnimation {
                                    selectedTimeZones.removeAll { $0 == tz }
                                    #if (iOS)
                                    notificationFeedbackGenerator.notificationOccurred(.success)
                                    #endif
                                }
                            }
                        }
                    }
            }
            .onMove(perform: move)
            .onDelete(perform: delete)
        }
        .listStyle(PlainListStyle())
        
    }
    
    @ViewBuilder
    var mykeModeButtons: some View {
        Button(action: {
            #if os(macOS)
            self.showTimeZonePopover = true
            #else
            self.showTimeZoneSheet = true
            #endif
        }) {
            Text("Choose time zones…")
            #if os(macOS)
                .foregroundColor(.primary)
            #endif
        }
        .popover(isPresented: $showTimeZonePopover, arrowEdge: .leading) {
            TimezoneChoiceView(selectedTimeZone: .constant(TimeZone.current), selectedTimeZones: $selectedTimeZones, selectedDate: $selectedDate, selectMultiple: true)
                .frame(minWidth: 300, minHeight: 300)
        }
        .padding(.vertical)
        
        if !isInPopover {
            Spacer()
        }
        
        CopyButton(text: "Copy", generateText: generateTimesAndFlagsText, showCopied: $showCopied)
        #if !os(macOS)
        ShareButton(generateText: generateTimesAndFlagsText)
        #endif
    }
    
    @ViewBuilder
    var dateTimeZonePicker: some View {
        
        Group {
            
            DateTimeZonePicker(selectedDate: $selectedDate, selectedTimeZone: $selectedTimeZone, showDate: false, maxWidth: nil)
                .padding(.top, 5)
                .padding(.horizontal, 8)
            
            Group {
                if isInPopover {
                    VStack {
                        mykeModeButtons
                    }
                } else {
                    HStack {
                        mykeModeButtons
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        
    }
    
    var body: some View {
        
        Group {
            
            if isOrientationLandscape && isRegularHorizontalSize {
                
                HStack(alignment: .top) {
                
                    VStack {
                        Text("Time Zone List")
                            .font(.title)
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        timeZoneList
                    }
                    
                    VStack {
                        dateTimeZonePicker
                        
                        Group {
                            Text("Text to be copied:")
                                .padding(.top)
                            Text(generateTimesAndFlagsText())
                                .padding(.horizontal)
                                .selectable()
                        }
                        .foregroundColor(.secondary)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                        
                    }
                    .padding()
                    
                }
                
            } else {
        
                ZStack(alignment: .top) {
                    
                    VStack {
                        
                        dateTimeZonePicker
                        
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 10)
                    .frame(minWidth: 0, maxWidth: 390)
                    .background(GeometryReader { geometry in
                        Color.clear.preference(
                            key: ViewHeightPreferenceKey.self,
                            value: geometry.size.height
                        )
                    })
                    .onPreferenceChange(ViewHeightPreferenceKey.self) {
                        selectionViewMaxHeight = $0
                    }
                    
                    timeZoneList
                        .padding(.top, (selectionViewMaxHeight ?? 0))
                    
                }
                
            }
            
        }
        .sheet(isPresented: $showTimeZoneSheet) {
            NavigationView {
                #if os(iOS)
                TimezoneChoiceView(selectedTimeZone: .constant(TimeZone.current), selectedTimeZones: $selectedTimeZones, selectedDate: $selectedDate, selectMultiple: true)
                    .navigationBarItems(trailing:
                                            Button(action: {
                        self.showTimeZoneSheet = false
                    }) {
                        Text("Done")
                    }
                    )
                #else
                TimezoneChoiceView(selectedTimeZone: .constant(TimeZone.current), selectedTimeZones: $selectedTimeZones, selectedDate: $selectedDate, selectMultiple: true)
                #endif
            }
        }
        .navigationViewStyle(Self.navigationViewStyle)
        .onAppear {
            selectedTimeZone = UserDefaults.shared.resetButtonTimeZone
            selectedTimeZones = UserDefaults.shared.mykeModeTimeZones
            timeZonesUsingEUFlag = UserDefaults.shared.mykeModeTimeZonesUsingEUFlag
            timeZonesUsing12HourTime = UserDefaults.shared.mykeModeTimeZoneIdentifiersUsing12HourTime
            timeZonesUsing24HourTime = UserDefaults.shared.mykeModeTimeZoneIdentifiersUsing24HourTime
        }
        .onChange(of: selectedTimeZones) { newValue in
            UserDefaults.shared.mykeModeTimeZones = newValue
        }
        .onChange(of: timeZonesUsingEUFlag) { newValue in
            UserDefaults.shared.mykeModeTimeZonesUsingEUFlag = newValue
        }
        .onChange(of: timeZonesUsing12HourTime) { newValue in
            UserDefaults.shared.mykeModeTimeZoneIdentifiersUsing12HourTime = newValue
        }
        .onChange(of: timeZonesUsing24HourTime) { newValue in
            UserDefaults.shared.mykeModeTimeZoneIdentifiersUsing24HourTime = newValue
        }
        
    }
    
    func move(from source: IndexSet, to destination: Int) {
        selectedTimeZones.move(fromOffsets: source, toOffset: destination)
    }
    
    func delete(at offsets: IndexSet) {
        selectedTimeZones.remove(atOffsets: offsets)
    }
    
}

private extension MykeMode {
    struct ViewHeightPreferenceKey: PreferenceKey {
        static let defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat,
                           nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}

struct MykeMode_Previews: PreviewProvider {
    static var previews: some View {
        #if !os(macOS)
        if #available(iOS 15.0, *) {
            MykeMode().environmentObject(OrientationObserver.shared)
        } else {
            MykeMode()
        }
        #else
        MykeMode()
        #endif
    }
}
