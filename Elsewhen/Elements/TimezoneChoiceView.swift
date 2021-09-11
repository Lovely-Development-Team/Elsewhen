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
    
    var body: some View {
        List {
            SearchBar(text: $searchTerm, placeholder: "Search...")
                .padding(.horizontal, -10)
            ForEach(filteredTimeZones(by: searchTerm), id: \.self) { tz in
                Button(action: {
                    self.selectedTimeZone = tz.identifier
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(tz.identifier.replacingOccurrences(of: "_", with: " "))
                        Spacer()
                        if let abbreviation = tz.abbreviation() {
                            Text(abbreviation)
                                .foregroundColor(selectedTimeZone == tz.identifier ? .accentColor : .secondary)
                        }
                    }
                    .foregroundColor(selectedTimeZone == tz.identifier ? .accentColor : .primary)
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Timezone")
    }
}

struct TimezoneChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        TimezoneChoiceView(selectedTimeZone: .constant("Europe/London"))
    }
}
