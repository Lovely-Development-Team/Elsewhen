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
        TimeZone.filtered(by: searchTerm).sorted {
            let t0IsFavourite = favouriteTimeZones.contains($0)
            let t1IsFavourite = favouriteTimeZones.contains($1)
            if t0IsFavourite && t1IsFavourite {
                return $0.identifier < $1.identifier
            }
            if t0IsFavourite {
                return true
            }
            if t1IsFavourite {
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
    
    var body: some View {
        List {
            #if os(iOS)
            SearchBar(text: $searchTerm, placeholder: "Search...")
                .padding(.horizontal, -10)
            #else
            Divider()
            #endif
            ForEach(sortedFilteredTimeZones, id: \.self) { tz in
                #if os(macOS)
                TimeZoneChoiceItem(tz: tz, isSelected: timeZoneIsSelected(tz), abbreviation: tz.fudgedAbbreviation(for: selectedDate), favouriteTimeZones: $favouriteTimeZones)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onSelect(tz: tz)
                    }
                Divider()
                #else
                Button(action: {
                    onSelect(tz: tz)
                }) {
                    TimeZoneChoiceItem(tz: tz, isSelected: timeZoneIsSelected(tz), abbreviation: tz.fudgedAbbreviation(for: selectedDate), favouriteTimeZones: $favouriteTimeZones)
                }
                #endif
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Time Zones")
        .inlineNavigationBarTitle()
        .onAppear {
            favouriteTimeZones = UserDefaults.standard.favouriteTimeZones
        }
        .onChange(of: favouriteTimeZones) { newValue in
            UserDefaults.standard.favouriteTimeZones = newValue
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
