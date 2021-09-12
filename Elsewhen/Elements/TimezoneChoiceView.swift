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
    @State private var searchTerm: String = ""
    
    private var filteredTimeZones: [TimeZone] {
        return TimeZone.knownTimeZoneIdentifiers.compactMap { tz in
            TimeZone(identifier: tz)
        }.filter { $0.matches(searchTerm: searchTerm) }
    }
    
    var body: some View {
        List {
            SearchBar(text: $searchTerm, placeholder: "Search...")
                .padding(.horizontal, -10)
            ForEach(filteredTimeZones(by: searchTerm), id: \.self) { tz in
                Button(action: {
                    self.selectedTimeZone = tz
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(tz.friendlyName)
                        Spacer()
                        if let abbreviation = tz.abbreviation() {
                            Text(abbreviation)
                                .foregroundColor(selectedTimeZone == tz ? .accentColor : .secondary)
                        }
                    }
                    .foregroundColor(selectedTimeZone == tz ? .accentColor : .primary)
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Timezone")
    }
}

struct TimezoneChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        TimezoneChoiceView(selectedTimeZone: .constant(TimeZone(identifier: "Europe/London")!))
    }
}
