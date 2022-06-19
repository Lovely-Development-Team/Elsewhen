//
//  MykeMode2.swift
//  Elsewhen
//
//  Created by Ben Cardy on 19/06/2022.
//

import SwiftUI
import UniformTypeIdentifiers

struct MykeMode2: View {
    
    // MARK: State
    @State private var selectedDate = Date()
    @State private var selectedTimeZone: TimeZone? = nil
    @State private var selectedFormatStyle: DateFormat = dateFormats[0]
    @State private var selectedTimeZones: [TimeZone] = []
    @State private var timeZonesUsingEUFlag: Set<TimeZone> = []
    @State private var timeZonesUsingNoFlag: Set<TimeZone> = []
    @State private var timeZonesUsing24HourTime: Set<TimeZone> = []
    @State private var timeZonesUsing12HourTime: Set<TimeZone> = []
    @State private var selectedTimeZoneGroup: TimeZoneGroup? = nil
    @State private var showCopied: Bool = false
    @State private var showTimeZoneGroupNameClashAlert: Bool = false
    @State private var pendingNewTimeZoneGroupName: String = ""
    @State private var viewId: Int = 0
    
    // MARK: Environment
    @EnvironmentObject private var timeZoneGroupController: MykeModeTimeZoneGroupsController
    
    // MARK: UserDefaults
    @AppStorage(UserDefaults.mykeModeDefaultTimeFormatKey, store: UserDefaults.shared) private var defaultTimeFormat: TimeFormat = .systemLocale
    @AppStorage(UserDefaults.mykeModeSeparatorKey, store: UserDefaults.shared) private var mykeModeSeparator: MykeModeSeparator = .hyphen
    @AppStorage(UserDefaults.mykeModeShowCitiesKey, store: UserDefaults.shared) private var mykeModeShowCities: Bool = false
    
    // MARK: Parameters
    
    let mediumImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    
    // MARK: Functions
    
    func generateTimesAndFlagsText() -> String {
        stringForTimesAndFlags(of: selectedDate, in: selectedTimeZone ?? TimeZone.current, for: selectedTimeZones, separator: mykeModeSeparator, timeZonesUsingEUFlag: timeZonesUsingEUFlag, timeZonesUsingNoFlag: timeZonesUsingNoFlag, showCities: mykeModeShowCities)
    }
    
    func stringForSelectedTime(in zone: TimeZone) -> String {
        stringFor(time: selectedDate, in: zone, sourceZone: selectedTimeZone ?? TimeZone.current)
    }
    
    func tzTapped(_ tz: TimeZone) {
        if flagForTimeZone(tz) != NoFlagTimeZoneEmoji {
            mediumImpactFeedbackGenerator.impactOccurred()
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
            notificationFeedbackGenerator.notificationOccurred(.success)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                showCopied = false
            }
        }
    }
    
#if !os(macOS)
    func showSaveGroupDialog(title: String, message: String, completion: @escaping (UIAlertAction, String) -> ()) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addTextField()
        let okAction = UIAlertAction(title: "Save", style: .default, handler: { action in
            completion(action, alertVC.textFields?.first?.text ?? "")
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        let viewController = UIApplication.shared.windows.first!.visibleViewController!
        viewController.present(alertVC, animated: true, completion: nil)
    }
#endif
    
    // MARK: View Builders
    
#if !os(macOS)
    @ViewBuilder
    var timeZoneGroupChoices: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { scrollViewReader in
                HStack {
                    ForEach(timeZoneGroupController.timeZoneGroups, id: \.name) { tzGroup in
                        Button(action: {
                            selectedTimeZoneGroup = tzGroup
                            withAnimation {
                                selectedTimeZones = tzGroup.timeZones
                            }
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
                .padding(.horizontal, 8)
                .onChange(of: selectedTimeZoneGroup) { target in
                    guard let target = target else { return }
                    withAnimation {
                        scrollViewReader.scrollTo(target.name, anchor: .center)
                    }
                }
            }
        }
    }
#endif
    
    
    @ViewBuilder
    var listFooter: some View {
        Text(generateTimesAndFlagsText().trimmingCharacters(in: .whitespacesAndNewlines))
            .foregroundColor(.secondary)
            .listRowSeparator(.hidden)
            .padding(.horizontal)
            .padding(.vertical, 8)
    }
    
    // MARK: Body
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                List {
                    Section(footer: listFooter) {
                        ForEach(selectedTimeZones, id: \.self) { tz in
                            SelectedTimeZoneCell2(tz: tz, timeInZone: stringForSelectedTime(in: tz), selectedDate: selectedDate, formattedString: stringForTimeAndFlag(in: tz, date: selectedDate, sourceZone: selectedTimeZone ?? TimeZone.current, separator: mykeModeSeparator, timeZonesUsingEUFlag: timeZonesUsingEUFlag, timeZonesUsingNoFlag: timeZonesUsingNoFlag, showCities: mykeModeShowCities), onTap: tzTapped)
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
                        .onMove(perform: move)
                        .onDelete(perform: delete)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                    }
                }
                .listStyle(.plain)
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(Color.systemBackground)
                .id(viewId)
                
                Button(action: {
                    postShowShareSheet(with: [generateTimesAndFlagsText()])
                }) {
//                    Text(showCopied ? "Copied ✓" : "Copy")
                    Image(systemName: "square.and.arrow.up")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(15)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                }
//                .roundedRectangle()
                .padding()
                
            }
            
            if !timeZoneGroupController.timeZoneGroups.isEmpty {
                timeZoneGroupChoices
                    .padding(.vertical)
                    .background(
                        ZStack {
                            Rectangle().fill(Color(UIColor.systemBackground))
                            RoundedCorner(cornerRadius: 15, corners: [.topLeft, .topRight])
                                .fill(Color(UIColor.secondarySystemBackground))
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 0)
                        }
                    )
            }
            
            DateTimeZoneSheet(selectedDate: $selectedDate, selectedTimeZone: .constant(TimeZone.current), selectedTimeZones: $selectedTimeZones, selectedTimeZoneGroup: $selectedTimeZoneGroup, multipleTimeZones: true, saveButtonTapped: { selectedTimeZones in
                
            })
            
        }
        .background(Color.secondarySystemBackground)
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

struct MykeMode2_Previews: PreviewProvider {
    static var previews: some View {
        MykeMode2().environmentObject(MykeModeTimeZoneGroupsController.shared)
    }
}
