//
//  MykeMode.swift
//  MykeMode
//
//  Created by Ben Cardy on 11/09/2021.
//

#if !os(macOS)
import UIKit
#endif
import SwiftUI
import UniformTypeIdentifiers

struct MykeMode: View, OrientationObserving {
    
    #if !os(macOS)
    @EnvironmentObject internal var orientationObserver: OrientationObserver
    @EnvironmentObject internal var timeZoneGroupController: MykeModeTimeZoneGroupsController
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
    
    @State private var selectedTimeZoneGroup: TimeZoneGroup? = nil
    
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
    
    @State private var showTimeZoneGroupNameClashAlert: Bool = false
    @State private var pendingNewTimeZoneGroupName: String = ""
    
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
        .padding(isInPopover ? .bottom : .vertical)
        
        Spacer()
        
        CopyButton(text: "Copy", generateText: generateTimesAndFlagsText, showCopied: $showCopied)
            .padding(isInPopover ? .bottom : [])
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
                HStack {
                    mykeModeButtons
                }
            }
            .padding(.horizontal, 8)
            
        }
        .padding(.horizontal, 8)
        
    }
    
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
                        .roundedRectangle(colour: selectedTimeZoneGroup == tzGroup ? .accentColor : .secondarySystemBackground, horizontalPadding: 14)
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
    
    var body: some View {
        
        Group {
            
            if isOrientationLandscape && isRegularHorizontalSize && !isInPopover {
                
                HStack(alignment: .top) {
                
                    VStack {
#if !os(macOS)
                        Text("Time Zone List")
                            .font(.title)
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        
                        timeZoneGroupChoices
#endif
                        
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
                            .frame(minWidth: 0, maxWidth: 390)
                        
#if !os(macOS)
                        timeZoneGroupChoices
                        #endif
                        
                    }
                    .padding(.bottom, 10)
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
                .padding(.top, isInPopover ? 15 : 0)
                
            }
            
        }
        .sheet(isPresented: $showTimeZoneSheet) {
            NavigationView {
                #if os(iOS)
                    TimezoneChoiceView(selectedTimeZone: .constant(TimeZone.current), selectedTimeZones: $selectedTimeZones, selectedDate: $selectedDate, selectMultiple: true)
                    .navigationBarItems(leading: Button(action: {
//                        showTimeZoneGroupNameClashAlert = true
                        self.showSaveGroupDialog(title: "Save as a Group?", message: "Provide a name for the Time Zone Group below.") { action, text in
                            if timeZoneGroupController.timeZoneGroups.map({ $0.name }).contains(text) {
                                pendingNewTimeZoneGroupName = text
                                showTimeZoneGroupNameClashAlert = true
                            } else {
                                let tzGroup = TimeZoneGroup(name: text, timeZones: selectedTimeZones)
                                timeZoneGroupController.addTimeZoneGroup(tzGroup)
                                selectedTimeZoneGroup = tzGroup
                                showTimeZoneSheet = false
                            }
                        }
                    }) {
                        Text("Save...")
                    }, trailing: Button(action: {
                        if let selectedTimeZoneGroup = selectedTimeZoneGroup, selectedTimeZones != selectedTimeZoneGroup.timeZones {
                            self.selectedTimeZoneGroup = nil
                        }
                        self.showTimeZoneSheet = false
                    }) {
                        Text("Done")
                    }
                    )
                    .alert(isPresented: $showTimeZoneGroupNameClashAlert) {
                        Alert(
                            title: Text("Group already exists"),
                            message: Text("Would you like to update the group \(pendingNewTimeZoneGroupName) with the selected Time Zones?"),
                            primaryButton: .default(Text("Update Group")) {
                                let tzGroup = timeZoneGroupController.retrieveTimeZoneGroup(byName: pendingNewTimeZoneGroupName)
                                timeZoneGroupController.updateTimeZoneGroup(tzGroup, with: selectedTimeZones)
                                selectedTimeZoneGroup = tzGroup
                                showTimeZoneSheet = false
                            },
                            secondaryButton: .cancel(Text("Cancel"))
                        )
                    }
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
    
    func move(from source: IndexSet, to destination: Int) {
        selectedTimeZones.move(fromOffsets: source, toOffset: destination)
        selectedTimeZoneGroup = nil
    }
    
    func delete(at offsets: IndexSet) {
        selectedTimeZones.remove(atOffsets: offsets)
        selectedTimeZoneGroup = nil
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
    
}

#if !os(macOS)
public extension UIWindow {
    var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }

    static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}
#endif

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
