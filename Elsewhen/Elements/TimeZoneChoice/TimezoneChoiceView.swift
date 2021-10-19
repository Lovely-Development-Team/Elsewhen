//
//  TimezoneChoiceView.swift
//  TimezoneChoiceView
//
//  Created by Ben Cardy on 06/09/2021.
//

import SwiftUI

struct TimezoneChoiceView: View {
    
    @Binding var selectedTimeZone: TimeZone
    @Binding var selectedTimeZones: [TimeZone]
    @Binding var selectedDate: Date
    var selectMultiple: Bool
    var done: (() -> ())?
    
    @State private var searchTerm: String = ""
    @State private var favouriteTimeZones: Set<TimeZone> = []
    
    private var sortedFilteredTimeZones: [TimeZone] {
        let selectedTimeZonesSet = Set(selectedTimeZones)
        return TimeZone.filtered(by: searchTerm).sorted {
            let t0IsFavourite = favouriteTimeZones.contains($0)
            let t1IsFavourite = favouriteTimeZones.contains($1)
            let t0IsSelected = selectedTimeZonesSet.contains($0)
            let t1IsSelected = selectedTimeZonesSet.contains($1)
            
            if t0IsFavourite && t1IsFavourite {
                return $0.identifier < $1.identifier
            }
            if t0IsFavourite {
                return true
            }
            if t1IsFavourite {
                return false
            }
            
            if t0IsSelected && t1IsSelected {
                return $0.identifier < $1.identifier
            }
            if t0IsSelected {
                return true
            }
            if t1IsSelected {
                return false
            }
            
            return $0.identifier < $1.identifier
        }
    }
    
    private func timeZoneIsSelected(_ tz: TimeZone) -> Bool {
        if selectMultiple {
            return selectedTimeZones.contains(tz)
        } else {
            return selectedTimeZone == tz
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
    
    var body: some View {
        List {
            #if os(iOS)
            SearchBar(text: $searchTerm, placeholder: "Search...")
                .padding(.horizontal, -10)
            #else
            SearchBar(text: $searchTerm, placeholder: "Search...")
            #endif
            ForEach(sortedFilteredTimeZones, id: \.self) { tz in
                let isFavourite = isFavouriteBinding(for: tz)
                TimeZoneChoiceCell(tz: tz, isSelected: timeZoneIsSelected(tz), abbreviation: tz.fudgedAbbreviation(for: selectedDate), isFavourite: isFavourite, onSelect: onSelect(tz:))
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Time Zones")
        .inlineNavigationBarTitle()
        .onAppear {
            favouriteTimeZones = UserDefaults.shared.favouriteTimeZones
        }
        .onChange(of: favouriteTimeZones) { newValue in
            UserDefaults.shared.favouriteTimeZones = newValue
        }
    }
    
    func onSelect(tz: TimeZone) {
        if self.selectMultiple {
            if let index = self.selectedTimeZones.firstIndex(of: tz) {
                self.selectedTimeZones.remove(at: index)
            } else {
                self.selectedTimeZones.append(tz)
            }
        } else {
            self.selectedTimeZone = tz
            done?()
        }
    }
}

struct TimezoneChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        TimezoneChoiceView(selectedTimeZone: .constant(TimeZone(identifier: "Africa/Accra")!), selectedTimeZones: .constant([TimeZone(identifier: "Africa/Algiers")!, TimeZone(identifier: "Africa/Bissau")!]), selectedDate: .constant(Date()), selectMultiple: true)
    }
}
