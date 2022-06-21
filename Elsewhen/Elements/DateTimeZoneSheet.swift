//
//  DateTimeZoneSheet.swift
//  Elsewhen
//
//  Created by Ben Cardy on 18/06/2022.
//

import SwiftUI

struct DateTimeZoneSheet: View {
    
    // MARK: Init arguments
    
    @Binding var selectedDate: Date
    @Binding var selectedTimeZone: TimeZone?
    @Binding var selectedTimeZones: [TimeZone]
    @Binding var selectedTimeZoneGroup: TimeZoneGroup?
    let multipleTimeZones: Bool
    
    // MARK: State
    
    @State private var showTimeZoneChoiceSheet: Bool = false
    
    var timeZoneLabel: String {
        multipleTimeZones ? "Time Zones" : "Time Zone"
    }
    
    var timeZoneButtonValue: String {
        multipleTimeZones ? "Choose Time Zones" : selectedTimeZone?.friendlyName ?? TimeZone.current.friendlyName
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Time").fontWeight(.semibold)
                Spacer()
                DatePicker("Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .labelsHidden()
                Button(action: {
                    withAnimation {
                        selectedDate = Date()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
                .hoverEffect()
            }
            HStack {
                Text(timeZoneLabel).fontWeight(.semibold)
                Spacer()
                Button(action: {
                    showTimeZoneChoiceSheet = true
                }) {
                    Text(timeZoneButtonValue)
                }
                .foregroundColor(.primary)
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .hoverEffect()
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(UIColor.systemGray5))
                )
            }
        }
        .padding([.horizontal, .bottom])
        .padding(.top, 10)
        .sheet(isPresented: $showTimeZoneChoiceSheet) {
            NavigationView {
                TimezoneChoiceView(selectedTimeZone: $selectedTimeZone, selectedTimeZones: $selectedTimeZones, selectedDate: $selectedDate, selectMultiple: multipleTimeZones) {
                    showTimeZoneChoiceSheet = false
                }
                .navigationBarItems(trailing: Button(action: {
                    if multipleTimeZones, let selectedTimeZoneGroup = selectedTimeZoneGroup, selectedTimeZones != selectedTimeZoneGroup.timeZones {
                        self.selectedTimeZoneGroup = nil
                    }
                    showTimeZoneChoiceSheet = false
                }) {
                    Text("Done")
                }
                )
            }
        }
    }
    
}

struct DateTimeZoneSheet_Previews: PreviewProvider {
    static var previews: some View {
        DateTimeZoneSheet(selectedDate: .constant(Date()), selectedTimeZone: .constant(nil), selectedTimeZones: .constant([]), selectedTimeZoneGroup: .constant(nil), multipleTimeZones: false)
    }
}
