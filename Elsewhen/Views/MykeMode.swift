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
    @State private var timeZonesUsingNoFlag: Set<TimeZone> = []
    @State private var timeZonesUsing24HourTime: Set<TimeZone> = []
    @State private var timeZonesUsing12HourTime: Set<TimeZone> = []
    
    @AppStorage(UserDefaults.mykeModeDefaultTimeFormatKey, store: UserDefaults.shared) private var defaultTimeFormat: TimeFormat = .systemLocale
    @AppStorage(UserDefaults.mykeModeSeparatorKey, store: UserDefaults.shared) private var mykeModeSeparator: MykeModeSeparator = .hyphen
    @AppStorage(UserDefaults.mykeModeShowCitiesKey, store: UserDefaults.shared) private var mykeModeShowCities: Bool = false
    
    @State private var showCopied: Bool = false
    
    #if os(iOS)
    let mediumImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    #endif
    
    @State private var showTimeZoneSheet: Bool = false
    @State private var showTimeZonePopover: Bool = false
    @State private var selectionViewMaxHeight: CGFloat?
    
    @State private var viewId: Int = 1
    
    func generateTimesAndFlagsText() -> String {
        stringForTimesAndFlags(of: selectedDate, in: selectedTimeZone ?? TimeZone.current, for: selectedTimeZones, separator: mykeModeSeparator, timeZonesUsingEUFlag: timeZonesUsingEUFlag, timeZonesUsingNoFlag: timeZonesUsingNoFlag, showCities: mykeModeShowCities)
    }
    
    func flagForTimeZone(_ tz: TimeZone, ignoringEUFlags: Bool = false) -> String {
        if !ignoringEUFlags && timeZonesUsingEUFlag.contains(tz) {
            return "🇪🇺"
        }
        return tz.flag
    }
    
    func stringForSelectedTime(in zone: TimeZone) -> String {
        stringFor(time: selectedDate, in: zone, sourceZone: selectedTimeZone ?? TimeZone.current)
    }
    
    #if os(iOS)
    static let navigationViewStyle = StackNavigationViewStyle()
    #else
    static let navigationViewStyle = DefaultNavigationViewStyle()
    #endif
    
    func tzTapped(_ tz: TimeZone) {
        if flagForTimeZone(tz) != NoFlagTimeZoneEmoji {
#if os(iOS)
            mediumImpactFeedbackGenerator.impactOccurred()
#endif
            if tz.isMemberOfEuropeanUnion {
                if timeZonesUsingNoFlag.contains(tz) {
                    timeZonesUsingNoFlag.remove(tz)
                    timeZonesUsingEUFlag.remove(tz)
                } else {
                    if timeZonesUsingEUFlag.contains(tz) {
                        timeZonesUsingEUFlag.remove(tz)
                        timeZonesUsingNoFlag.insert(tz)
                    } else {
                        timeZonesUsingEUFlag.insert(tz)
                    }
                }
            } else {
                if timeZonesUsingNoFlag.contains(tz) {
                    timeZonesUsingNoFlag.remove(tz)
                } else {
                    timeZonesUsingNoFlag.insert(tz)
                }
            }
        }
    }
    
    @ViewBuilder
    var timeZoneList: some View {
        
        List {
            ForEach(selectedTimeZones, id: \.identifier) { tz in
                SelectedTimeZoneCell(tz: tz, timeInZone: stringForSelectedTime(in: tz), selectedDate: selectedDate, formattedString: stringForTimeAndFlag(in: tz, date: selectedDate, sourceZone: selectedTimeZone ?? TimeZone.current, separator: mykeModeSeparator, timeZonesUsingEUFlag: timeZonesUsingEUFlag, timeZonesUsingNoFlag: timeZonesUsingNoFlag, showCities: mykeModeShowCities), onTap: tzTapped)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
#if os(iOS)
                    .onTapGesture {
                        tzTapped(tz)
                    }
#endif
                    .contextMenu {
                        if flagForTimeZone(tz) != NoFlagTimeZoneEmoji {
                            Button(action: {
                                #if os(iOS)
                                mediumImpactFeedbackGenerator.impactOccurred()
                                #endif
                                timeZonesUsingNoFlag.insert(tz)
                            }) {
                                Text("\(NoFlagTimeZoneEmoji) Use Clock Emoji")
                            }
                            Button(action: {
                                #if os(iOS)
                                mediumImpactFeedbackGenerator.impactOccurred()
                                #endif
                                timeZonesUsingNoFlag.remove(tz)
                                timeZonesUsingEUFlag.remove(tz)
                            }) {
                                Text("\(flagForTimeZone(tz, ignoringEUFlags: true)) Use Country Flag")
                            }
                            if tz.isMemberOfEuropeanUnion {
                                Button(action: {
                                    #if os(iOS)
                                    mediumImpactFeedbackGenerator.impactOccurred()
                                    #endif
                                    timeZonesUsingNoFlag.remove(tz)
                                    timeZonesUsingEUFlag.insert(tz)
                                }) {
                                    Text("🇪🇺 Use EU Flag")
                                }
                            }
                            Divider()
                        }
                        Button(action: {
                            #if os(iOS)
                            mediumImpactFeedbackGenerator.impactOccurred()
                            #endif
                            self.timeZonesUsing24HourTime.remove(tz)
                            self.timeZonesUsing12HourTime.insert(tz)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                self.viewId += 1
                            }
                        }) {
                            Text("12-Hour Time Format")
                        }
                        Button(action: {
                            #if os(iOS)
                            mediumImpactFeedbackGenerator.impactOccurred()
                            #endif
                            self.timeZonesUsing12HourTime.remove(tz)
                            self.timeZonesUsing24HourTime.insert(tz)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                self.viewId += 1
                            }
                        }) {
                            Text("24-Hour Time Format")
                        }
                        Button(action: {
                            #if os(iOS)
                            mediumImpactFeedbackGenerator.impactOccurred()
                            #endif
                            self.timeZonesUsing12HourTime.remove(tz)
                            self.timeZonesUsing24HourTime.remove(tz)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                self.viewId += 1
                            }
                        }) {
                            Text("Default Time Format")
                        }
                        Divider()
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
        .id(viewId)
        
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
            
            DateTimeZonePicker(selectedDate: $selectedDate, selectedTimeZone: $selectedTimeZone, showFullCalendar: false, maxWidth: nil)
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
            timeZonesUsingNoFlag = UserDefaults.shared.mykeModeTimeZonesUsingNoFlag
            timeZonesUsing12HourTime = UserDefaults.shared.mykeModeTimeZoneIdentifiersUsing12HourTime
            timeZonesUsing24HourTime = UserDefaults.shared.mykeModeTimeZoneIdentifiersUsing24HourTime
        }
        .onChange(of: selectedTimeZones) { newValue in
            UserDefaults.shared.mykeModeTimeZones = newValue
        }
        .onChange(of: timeZonesUsingEUFlag) { newValue in
            UserDefaults.shared.mykeModeTimeZonesUsingEUFlag = newValue
        }
        .onChange(of: timeZonesUsingNoFlag) { newValue in
            UserDefaults.shared.mykeModeTimeZonesUsingNoFlag = newValue
        }
        .onChange(of: timeZonesUsing12HourTime) { newValue in
            UserDefaults.shared.mykeModeTimeZoneIdentifiersUsing12HourTime = newValue
        }
        .onChange(of: timeZonesUsing24HourTime) { newValue in
            UserDefaults.shared.mykeModeTimeZoneIdentifiersUsing24HourTime = newValue
        }
        .onChange(of: defaultTimeFormat) { newValue in
            /// This is purely here to update the view state when the user changes the default time format in settings
            return
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
