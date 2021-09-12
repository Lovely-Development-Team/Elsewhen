//
//  TimezoneChoiceView.swift
//  TimezoneChoiceView
//
//  Created by Ben Cardy on 06/09/2021.
//

import SwiftUI

struct TimezoneChoiceView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @Binding var selectedTimeZone: TimeZone
    @Binding var selectedTimeZones: [TimeZone]
    @Binding var selectedDate: Date
    var selectMultiple: Bool
    @State private var searchTerm: String = ""
    
    private var filteredTimeZones: [TimeZone] {
        return TimeZone.knownTimeZoneIdentifiers.compactMap { tz in
            TimeZone(identifier: tz)
        }.filter { $0.matches(searchTerm: searchTerm) }
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
            ForEach(filteredTimeZones(by: searchTerm), id: \.self) { tz in
                Button(action: {
                    if self.selectMultiple {
                        if let index = self.selectedTimeZones.firstIndex(of: tz) {
                            self.selectedTimeZones.remove(at: index)
                        } else {
                            self.selectedTimeZones.append(tz)
                        }
                    } else {
                        self.selectedTimeZone = tz
                    }
                    if !selectMultiple {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    HStack {
                        Text(tz.friendlyName)
                        Spacer()
                        if let abbreviation = tz.fudgedAbbreviation(for: selectedDate) {
                            Text(abbreviation)
                                .foregroundColor(.secondary)
                        }
                        if timeZoneIsSelected(tz) {
                            Image(systemName: "checkmark")
                        }
                    }
                    .foregroundColor(timeZoneIsSelected(tz) ? .accentColor : .primary)
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Timezone")
    }
}

struct TimezoneChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        TimezoneChoiceView(selectedTimeZone: .constant(TimeZone(identifier: "Africa/Accra")!), selectedTimeZones: .constant([TimeZone(identifier: "Africa/Algiers")!, TimeZone(identifier: "Africa/Bissau")!]), selectedDate: .constant(Date()), selectMultiple: true)
    }
}
