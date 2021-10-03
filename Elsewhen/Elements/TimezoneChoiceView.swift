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
    
    private var groupedTimeZones: [String: [TimeZone]] {
        Dictionary(grouping: sortedFilteredTimeZones) { tz in
            if favouriteTimeZones.contains(tz) {
                return "1 Favourites"
            } else {
                return tz.friendlyIdentifierContinent
            }
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
            SearchBar(text: $searchTerm, placeholder: "Search...")
                .padding(.horizontal, -10)
            ForEach(Array(groupedTimeZones.keys).sorted(), id: \.self) { groupName in
                Section(header: Text(groupName.replacingOccurrences(of: "1 ", with: ""))) {
                    ForEach(groupedTimeZones[groupName]!, id: \.self) { tz in
                        Button(action: {
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
                        }) {
                            TimeZoneChoiceItem(tz: tz, isSelected: timeZoneIsSelected(tz), abbreviation: tz.fudgedAbbreviation(for: selectedDate), favouriteTimeZones: $favouriteTimeZones)
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Time Zones")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            favouriteTimeZones = UserDefaults.standard.favouriteTimeZones
        }
        .onChange(of: favouriteTimeZones) { newValue in
            UserDefaults.standard.favouriteTimeZones = newValue
        }
    }
}

struct TimezoneChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        TimezoneChoiceView(selectedTimeZone: .constant(TimeZone(identifier: "Africa/Accra")!), selectedTimeZones: .constant([TimeZone(identifier: "Africa/Algiers")!, TimeZone(identifier: "Africa/Bissau")!]), selectedDate: .constant(Date()), selectMultiple: true)
    }
}
