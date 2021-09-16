//
//  DateTimeZonePicker.swift
//  DateTimeZonePicker
//
//  Created by Ben Cardy on 11/09/2021.
//

import SwiftUI

struct DateTimeZonePicker: View {
    
    @Binding var selectedDate: Date
    @Binding var selectedTimeZone: TimeZone
    
    var showDate: Bool = true
    @State private var showTimeZoneChoiceSheet: Bool = false
    
    var body: some View {
        Group {
            
            if showDate {
                DatePicker("Date", selection: $selectedDate)
                    .datePickerStyle(.graphical)
                    .padding(.top)
            } else {
                HStack {
                    Text("Time")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                    Spacer()
                    DatePicker("Time", selection: $selectedDate, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(.graphical)
                }
            }
            
            HStack {
                Text("Time zone")
                    .fontWeight(.semibold)
                Spacer()
                SelectTimeZoneButton(selectedTimeZone: $selectedTimeZone) {
                    self.showTimeZoneChoiceSheet = true
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 10)
            .frame(minWidth: 0, maxWidth: 390)
            .sheet(isPresented: $showTimeZoneChoiceSheet) {
                NavigationView {
                    TimezoneChoiceView(selectedTimeZone: $selectedTimeZone, selectedTimeZones: .constant([]), selectedDate: $selectedDate, selectMultiple: false) {
                        showTimeZoneChoiceSheet = false
                    }
                }
            }
        }
    }
}

struct DateTimeZonePicker_Previews: PreviewProvider {
    static var previews: some View {
        DateTimeZonePicker(selectedDate: .constant(Date()), selectedTimeZone: .constant(TimeZone(identifier: "Europe/London")!), showDate: false)
    }
}
