//
//  TimezoneChoiceView.swift
//  TimezoneChoiceView
//
//  Created by Ben Cardy on 06/09/2021.
//

import SwiftUI

struct TimezoneChoiceView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @Binding var selectedTimeZone: String
    @State private var searchTerm: String = ""
    
    private var filteredTimeZones: [String] {
        let st = searchTerm.trimmingCharacters(in: .whitespaces).lowercased().replacingOccurrences(of: " ", with: "_")
        return TimeZone.knownTimeZoneIdentifiers.filter { tz in
            if st == "" {
                return true
            }
            if tz.lowercased().contains(st) {
                return true
            }
            return false
        }
    }
    
    var body: some View {
        List {
            SearchBar(text: $searchTerm, placeholder: "Search...")
                .padding(.horizontal, -10)
            ForEach(filteredTimeZones, id: \.self) { tz in
                Button(action: {
                    self.selectedTimeZone = tz
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(tz.replacingOccurrences(of: "_", with: " "))
                        if selectedTimeZone == tz {
                            Spacer()
                            Image(systemName: "checkmark")
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
        TimezoneChoiceView(selectedTimeZone: .constant("Africa/Accra"))
    }
}
