//
//  TimezoneChoiceView.swift
//  TimezoneChoiceView
//
//  Created by Ben Cardy on 06/09/2021.
//

import SwiftUI
import CoreLocation

struct TimezoneChoiceView: View, OrientationObserving {
    
    @Environment(\.presentationMode) var presentationMode
    #if !os(macOS)
    @EnvironmentObject internal var orientationObserver: OrientationObserver
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    
    @Binding var selectedTimeZone: TimeZone?
    @Binding var selectedTimeZones: [TimeZone]
    @Binding var selectedDate: Date
    let selectMultiple: Bool
    let showDeviceLocalOption: Bool
    let done: (() -> ())?
    
    @AppStorage(UserDefaults.useMapKitSearchKey) private var useMapKitSearch: Bool = true
    
    init(selectedTimeZone: Binding<TimeZone?>, selectedTimeZones: Binding<[TimeZone]>, selectedDate: Binding<Date>, selectMultiple: Bool, showDeviceLocalOption: Bool = false, done: (() -> ())? = nil) {
        self._selectedTimeZone = selectedTimeZone
        self._selectedTimeZones = selectedTimeZones
        self._selectedDate = selectedDate
        self.selectMultiple = selectMultiple
        self.showDeviceLocalOption = showDeviceLocalOption
        self.done = done
    }
    
    @State private var searchTerm: String = ""
    @State private var favouriteTimeZones: Set<TimeZone> = []
    
    @StateObject private var searchController = TimeZoneSearchController()
    
    #if os(iOS)
    let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    #endif
    
    private func timeZoneSortFunction(_ t0: TimeZone, _ t1: TimeZone) -> Bool {
        let t0IsFavourite = favouriteTimeZones.contains(t0)
        let t1IsFavourite = favouriteTimeZones.contains(t1)
        let t0IsSelected = selectedTimeZones.contains(t0)
        let t1IsSelected = selectedTimeZones.contains(t1)
        
        if t0IsFavourite && t1IsFavourite {
            return t0.identifier < t1.identifier
        }
        if t0IsFavourite {
            return true
        }
        if t1IsFavourite {
            return false
        }
        
        if t0IsSelected && t1IsSelected {
            return t0.identifier < t1.identifier
        }
        if t0IsSelected {
            return true
        }
        if t1IsSelected {
            return false
        }
        
        return t0.identifier < t1.identifier
    }
    
    private var sortedFoundTimeZones: [TimeZone] {
        let otherTimeZones = Set(filteredTimeZones)
        return searchController.results.filter {
            !otherTimeZones.contains($0)
        }.sorted(by: timeZoneSortFunction)
    }
    
    private var filteredTimeZones: [TimeZone] {
        TimeZone.filtered(by: searchTerm, onDate: selectedDate)
    }
    
    private var sortedFilteredTimeZones: [TimeZone] {
        filteredTimeZones.sorted(by: timeZoneSortFunction)
    }
    
    private func timeZoneIsSelected(_ tz: TimeZone) -> Bool {
        if selectMultiple {
            return selectedTimeZones.contains(tz)
        } else {
            return selectedTimeZone == tz || (selectedTimeZone == nil && tz == TimeZone.current && !showDeviceLocalOption)
        }
    }
    
    func isFavouriteBinding(for tz: TimeZone) -> Binding<Bool> {
        Binding {
            favouriteTimeZones.contains(tz)
        } set: { newValue in
            if newValue {
                favouriteTimeZones.insert(tz)
            } else {
                favouriteTimeZones.remove(tz)
            }
        }
    }
    
    var content: some View {
        List {
            #if os(iOS)
            SearchBar(text: $searchTerm, placeholder: "Search...")
                .padding(.horizontal, -10)
            #else
            SearchBar(text: $searchTerm, placeholder: "Search...")
            #endif
            if showDeviceLocalOption {
                LocalDeviceButton(isSelected: selectedTimeZone == nil, foregroundColour: selectedTimeZone == nil ? .accentColor : .primary) {
                    selectedTimeZone = nil
                    #if os(iOS)
                    selectionFeedbackGenerator.selectionChanged()
                    #endif
                    if !self.selectMultiple {
                        callDone()
                    }
                }
            }
            ForEach(sortedFilteredTimeZones, id: \.self) { tz in
                let isFavourite = isFavouriteBinding(for: tz)
                TimeZoneChoiceCell(tz: tz, isSelected: timeZoneIsSelected(tz), abbreviation: tz.fudgedAbbreviation(for: selectedDate), isFavourite: isFavourite, onSelect: onSelect(tz:), isFromLocationSearch: false, isButton: true)
            }
            if !searchController.results.isEmpty {
                ForEach(sortedFoundTimeZones, id: \.self) { tz in
                    let isFavourite = isFavouriteBinding(for: tz)
                    TimeZoneChoiceCell(tz: tz, isSelected: timeZoneIsSelected(tz), abbreviation: tz.fudgedAbbreviation(for: selectedDate), isFavourite: isFavourite, onSelect: onSelect(tz:), isFromLocationSearch: true, isButton: true)
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle(showDeviceLocalOption ? "DEFAULT_TIME_ZONE_TITLE" : "TIME_ZONE_PLURAL")
        .inlineNavigationBarTitle()
        .onAppear {
            favouriteTimeZones = UserDefaults.shared.favouriteTimeZones
        }
        .onChange(of: favouriteTimeZones) { newValue in
            UserDefaults.shared.favouriteTimeZones = newValue
        }
        .onChange(of: searchTerm) { newTerm in
            guard useMapKitSearch else { return }
            searchController.cancelPending()
            if newTerm != "" {
                searchController.search(for: newTerm)
            }
        }
    }
    
    var body: some View {
        if isPadAndNotCompact {
            NavigationView {
                content
                    .navigationTitle("DEFAULT_TIME_ZONE_TITLE")
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
            }
            #if os(iOS)
            .navigationViewStyle(StackNavigationViewStyle())
            #endif
        } else {
            content
        }
    }
    
    func onSelect(tz: TimeZone) {
        #if os(iOS)
        selectionFeedbackGenerator.prepare()
        #endif
        if self.selectMultiple {
            withAnimation {
                if let index = self.selectedTimeZones.firstIndex(of: tz) {
                    self.selectedTimeZones.remove(at: index)
                } else {
                    self.selectedTimeZones.append(tz)
                }
            }
            #if os(iOS)
            selectionFeedbackGenerator.selectionChanged()
            #endif
        } else {
            self.selectedTimeZone = tz
            #if os(iOS)
            selectionFeedbackGenerator.selectionChanged()
            #endif
            callDone()
        }
    }
    
    func callDone() {
        searchController.cancelPending()
        if let done = done {
            done()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
}

struct TimezoneChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TimezoneChoiceView(selectedTimeZone: .constant(TimeZone(identifier: "Africa/Accra")!), selectedTimeZones: .constant([TimeZone(identifier: "Africa/Algiers")!, TimeZone(identifier: "Africa/Bissau")!]), selectedDate: .constant(Date()), selectMultiple: true, showDeviceLocalOption: true)
#if os(iOS)
                .environmentObject(OrientationObserver())
#endif
        }
    }
}

struct LocalDeviceButton: View {
    let isSelected: Bool
    let foregroundColour: Color
    let onTap: () -> ()
    
    var body: some View {
        #if !os(macOS)
        Button(action: onTap) {
            LocalDeviceButtonContents(isSelected: isSelected)
            .foregroundColor(foregroundColour)
        }
        #else
        VStack {
            LocalDeviceButtonContents(isSelected: isSelected)
            Divider()
        }
        .foregroundColor(foregroundColour)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        #endif
    }
}

struct LocalDeviceButtonContents: View {
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Text("DEVICE")
            Spacer()
            Text("(\(TimeZone.current.friendlyName))")
                .foregroundColor(.secondary)
            if isSelected {
                Image(systemName: "checkmark")
            }
        }
    }
}
