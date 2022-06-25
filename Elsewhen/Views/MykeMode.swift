//
//  MykeMode.swift
//  Elsewhen
//
//  Created by Ben Cardy on 19/06/2022.
//

import SwiftUI
import UniformTypeIdentifiers

struct MykeMode: View {
    
    // MARK: State
    @State private var selectedTimeZone: TimeZone? = nil
    @State private var selectedFormatStyle: DateFormat = dateFormats[0]
    @State private var selectedTimeZones: [TimeZone] = []
    @State private var timeZonesUsingEUFlag: Set<TimeZone> = []
    @State private var timeZonesUsingNoFlag: Set<TimeZone> = []
    @State private var timeZonesUsing24HourTime: Set<TimeZone> = []
    @State private var timeZonesUsing12HourTime: Set<TimeZone> = []
    @State private var selectedTimeZoneGroup: TimeZoneGroup? = nil
    @State private var showCopied: Bool = false
    @State private var showNewTimeZoneGroupSheet: Bool = false
    @State private var showTimeZoneGroupNameClashAlert: Bool = false
    @State private var pendingNewTimeZoneGroupName: String = ""
    @State private var viewId: Int = 0
    
    // MARK: Environment
    @EnvironmentObject private var timeZoneGroupController: MykeModeTimeZoneGroupsController
    @EnvironmentObject var dateHolder: DateHolder
    
    // MARK: UserDefaults
    @AppStorage(UserDefaults.mykeModeDefaultTimeFormatKey, store: UserDefaults.shared) private var defaultTimeFormat: TimeFormat = .systemLocale
    @AppStorage(UserDefaults.mykeModeSeparatorKey, store: UserDefaults.shared) private var mykeModeSeparator: MykeModeSeparator = .hyphen
    @AppStorage(UserDefaults.mykeModeShowCitiesKey, store: UserDefaults.shared) private var mykeModeShowCities: Bool = false
    
    // MARK: Parameters
    
#if os(iOS)
    let mediumImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
#endif
    
    // MARK: Functions
    
    func generateTimesAndFlagsText() -> String {
        stringForTimesAndFlags(of: dateHolder.date, in: selectedTimeZone ?? TimeZone.current, for: selectedTimeZones, separator: mykeModeSeparator, timeZonesUsingEUFlag: timeZonesUsingEUFlag, timeZonesUsingNoFlag: timeZonesUsingNoFlag, showCities: mykeModeShowCities)
    }
    
    func stringForSelectedTime(in zone: TimeZone) -> String {
        stringFor(time: dateHolder.date, in: zone, sourceZone: selectedTimeZone ?? TimeZone.current)
    }
    
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
    
    func flagForTimeZone(_ tz: TimeZone, ignoringEUFlags: Bool = false) -> String {
        if !ignoringEUFlags && timeZonesUsingEUFlag.contains(tz) {
            return "🇪🇺"
        }
        return tz.flag
    }
    
    func copyText() {
        EWPasteboard.set(generateTimesAndFlagsText(), forType: UTType.utf8PlainText)
        withAnimation {
            showCopied = true
#if os(iOS)
            notificationFeedbackGenerator.notificationOccurred(.success)
#endif
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                showCopied = false
            }
        }
    }
    
    // MARK: View Builders
    
    @ViewBuilder
    var timeZoneGroupChoices: some View {
    #if !os(macOS)
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { scrollViewReader in
                HStack {
                    ForEach(timeZoneGroupController.timeZoneGroups, id: \.name) { tzGroup in
                        Button(action: {
                            selectedTimeZoneGroup = tzGroup
                        }) {
                            Text(tzGroup.name)
                                .foregroundColor(selectedTimeZoneGroup == tzGroup ? .white : .primary)
                        }
                        .roundedRectangle(colour: selectedTimeZoneGroup == tzGroup ? .accentColor : Color(UIColor.systemGray5), horizontalPadding: 14, cornerRadius: 10)
                        .contentShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                        .contextMenu {
                            Button(action: {
                                selectedTimeZoneGroup = tzGroup
                                timeZoneGroupController.updateTimeZoneGroup(tzGroup, with: selectedTimeZones)
                            }) {
                                Text("Update Group")
                            }
                            Button(action: {
                                postShowShareSheet(with: [tzGroup.exportText])
                            }) {
                                Label("Share Group", systemImage: "square.and.arrow.up")
                            }
                            Divider()
                            DeleteButton(text: "Remove Group") {
                                timeZoneGroupController.removeTimeZoneGroup(tzGroup)
                            }
                        }
                        .id(tzGroup.name)
                    }
                }
                .padding(.bottom, 2)
                .padding(.horizontal)
                .onChange(of: selectedTimeZoneGroup) { target in
                    guard let target = target else { return }
                    withAnimation {
                        scrollViewReader.scrollTo(target.name, anchor: .center)
                    }
                }
            }
        }
        .padding(.vertical, 10)
        #else
        HStack {
            Picker("Group", selection: $selectedTimeZoneGroup) {
                Text("Group...").tag(TimeZoneGroup?.none)
                ForEach(timeZoneGroupController.timeZoneGroups, id: \.name) { tzGroup in
                    Text(tzGroup.name).tag(TimeZoneGroup?.some(tzGroup))
                }
            }
            .labelsHidden()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        #endif
    }
    
    
    @ViewBuilder
    var listFooter: some View {
        Text(generateTimesAndFlagsText().trimmingCharacters(in: .whitespacesAndNewlines))
            .foregroundColor(.secondary)
#if os(iOS)
            .listRowSeparator(.hidden)
#endif
            .padding(.horizontal)
            .padding(.vertical, 8)
    }
    
    @ViewBuilder
    func timeZoneListItem(for tz: TimeZone) -> some View {
        SelectedTimeZoneCell(tz: tz, timeInZone: stringForSelectedTime(in: tz), selectedDate: dateHolder.date, formattedString: stringForTimeAndFlag(in: tz, date: dateHolder.date, sourceZone: selectedTimeZone ?? TimeZone.current, separator: mykeModeSeparator, timeZonesUsingEUFlag: timeZonesUsingEUFlag, timeZonesUsingNoFlag: timeZonesUsingNoFlag, showCities: mykeModeShowCities), onTap: tzTapped)
#if os(iOS)
            .hoverEffect()
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
                DeleteButton(text: "Remove from List") {
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
    
    // MARK: Body
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                List {
                    Section {
                        ForEach(selectedTimeZones, id: \.self) { tz in
                            #if os(macOS)
                            HStack {
                                timeZoneListItem(for: tz)
                                Image(systemName: "line.3.horizontal")
                            }
                            #else
                            timeZoneListItem(for: tz)
                            #endif
                        }
                        .onMove(perform: move)
                        .onDelete(perform: delete)
                        .padding(.vertical, 5)
                        .padding(.leading)
#if os(iOS)
                        .padding(.trailing)
                        .listRowSeparator(.hidden)
                        #else
                        .padding(.trailing, 8)
#endif
                        .listRowInsets(EdgeInsets())
                    } header: {
                        #if os(macOS)
                        if !timeZoneGroupController.timeZoneGroups.isEmpty {
                            timeZoneGroupChoices
                        }
                        #endif
                    } footer: {
                        listFooter
                    }
                }
                .listStyle(.plain)
                .frame(minWidth: 0, maxWidth: .infinity)
                .clipped()
                .background(Color.systemBackground)
                .id(viewId)
                
#if os(iOS)
                HStack(spacing: 0) {
                    Button(action: {
                        postShowShareSheet(with: [generateTimesAndFlagsText()])
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(15)
                            .padding(.leading, 5)
                            .frame(maxHeight: .infinity)
                            .background(Color.accentColor)
                            .clipShape(RoundedCorner(cornerRadius: 25, corners: [.topLeft, .bottomLeft]))
                            .hoverEffect()
                    }
                    Divider()
                    Button(action: copyText) {
                        ZStack {
                            Group {
                                Image(systemName: "doc.on.doc").opacity(0)
                                Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(15)
                            .padding(.trailing, 5)
                            .frame(maxHeight: .infinity)
                            .background(Color.accentColor)
                            .clipShape(RoundedCorner(cornerRadius: 25, corners: [.topRight, .bottomRight]))
                            .hoverEffect()
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxHeight: 100, alignment: .bottom)
                .padding()
#endif
                
            }
            
            VStack {
                #if os(iOS)
                if !timeZoneGroupController.timeZoneGroups.isEmpty {
                    timeZoneGroupChoices
                    Divider()
                        .padding(.horizontal)
                }
                #endif
                HStack {
                    
#if os(iOS)
                    Button(action: {
                        showNewTimeZoneGroupSheet = true
                    }) {
                        #if os(iOS)
                        Label("Save as Group", systemImage: "plus.square")
                        #else
                        Text("Save as Group&hellip;")
                        #endif
                    }
                    .padding(.leading, 12)
                    .padding(.vertical, 10)
                    .padding(.trailing)
                    .hoverEffect()
#endif
                    
                    #if os(iOS)
                    Spacer()
                    #endif
                    
                    Button(action: {
                        withAnimation {
                            selectedTimeZones = selectedTimeZones.sorted { tz1, tz2 in
                                let tz1offset = tz1.secondsFromGMT(for: dateHolder.date)
                                let tz2offset = tz2.secondsFromGMT(for: dateHolder.date)
                                if tz1offset == tz2offset {
                                    return tz1.identifier < tz2.identifier
                                }
                                return tz1offset < tz2offset
                            }
                            if let selectedTimeZoneGroup = selectedTimeZoneGroup {
                                if selectedTimeZoneGroup.timeZones != selectedTimeZones {
                                    self.selectedTimeZoneGroup = nil
                                }
                            }
                        }
                    }) {
                        #if os(iOS)
                        Label("Sort by Time", systemImage: "arrow.up.arrow.down")
                        #else
                        Text("Sort by Time")
                        #endif
                    }
                    .padding(.trailing)
                    .padding(.leading, 12)
                    .padding(.vertical, 10)
#if os(iOS)
                    .hoverEffect()
                    #endif
                    
                    #if os(macOS)
                    Spacer()
                    Text("Copied!").opacity(showCopied ? 1 : 0)
                    Button(action: copyText) {
                        Text("Copy")
                    }
                    .padding(.trailing, 8)
                    .keyboardShortcut("c", modifiers: [.command])
                    #endif
                    
                }
                .padding(.horizontal, 8)
                Divider()
                    .padding(.horizontal)
                DateTimeZoneSheet(selectedDate: $dateHolder.date, selectedTimeZone: .constant(TimeZone.current), selectedTimeZones: $selectedTimeZones, selectedTimeZoneGroup: $selectedTimeZoneGroup, multipleTimeZones: true)
            }
            .padding(.top, 10)
            .background(
                ZStack {
                    Rectangle().fill(Color.systemBackground)
#if os(iOS)
                    RoundedCorner(cornerRadius: 15, corners: [.topLeft, .topRight])
                        .fill(Color.secondarySystemBackground)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 0)
                    #endif
                }
            )
#if os(macOS)
            .overlay(
                Rectangle().frame(width: nil, height: 1, alignment: .top).foregroundColor(Color.secondary.opacity(0.3)), alignment: .top
            )
#endif
        }
        .background(Color.secondarySystemBackground)
#if os(iOS)
        .sheet(isPresented: $showNewTimeZoneGroupSheet) {
            NavigationView {
                NewTimeZoneGroupView(selectedTimeZones: $selectedTimeZones, selectedTimeZoneGroup: $selectedTimeZoneGroup, sheetIsPresented: $showNewTimeZoneGroupSheet)
                    .navigationTitle("Save")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(leading: Button(action: {
                            showNewTimeZoneGroupSheet = false
                        }) {
                            Text("Cancel")
                        }
                    )
            }
        }
#endif
        .onAppear {
            selectedTimeZone = UserDefaults.shared.resetButtonTimeZone
            selectedTimeZones = UserDefaults.shared.mykeModeTimeZones
            timeZonesUsingEUFlag = UserDefaults.shared.mykeModeTimeZonesUsingEUFlag
            timeZonesUsingNoFlag = UserDefaults.shared.mykeModeTimeZonesUsingNoFlag
            timeZonesUsing12HourTime = UserDefaults.shared.mykeModeTimeZoneIdentifiersUsing12HourTime
            timeZonesUsing24HourTime = UserDefaults.shared.mykeModeTimeZoneIdentifiersUsing24HourTime
#if !os(macOS)
            if let mykeModeTimeZoneGroupName = UserDefaults.shared.mykeModeTimeZoneGroupName {
                for group in timeZoneGroupController.timeZoneGroups {
                    if group.name == mykeModeTimeZoneGroupName {
                        selectedTimeZoneGroup = group
                        break
                    }
                }
            } else {
                selectedTimeZoneGroup = nil
            }
#endif
        }
        .onChange(of: selectedTimeZones) { newValue in
            UserDefaults.shared.mykeModeTimeZones = newValue
        }
        .onChange(of: selectedTimeZoneGroup) { newValue in
            if let newValue = newValue {
                withAnimation {
                    selectedTimeZones = newValue.timeZones
                }
                UserDefaults.shared.mykeModeTimeZoneGroupName = newValue.name
            } else {
                UserDefaults.shared.mykeModeTimeZoneGroupName = nil
            }
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
    
    // MARK: List Operations
    
    func move(from source: IndexSet, to destination: Int) {
        selectedTimeZones.move(fromOffsets: source, toOffset: destination)
        selectedTimeZoneGroup = nil
    }
    
    func delete(at offsets: IndexSet) {
        selectedTimeZones.remove(atOffsets: offsets)
        selectedTimeZoneGroup = nil
    }
    
}

struct MykeMode_Previews: PreviewProvider {
    static var previews: some View {
        MykeMode().environmentObject(MykeModeTimeZoneGroupsController.shared).environmentObject(DateHolder.shared)
    }
}
