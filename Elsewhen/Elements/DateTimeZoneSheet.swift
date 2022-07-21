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
#if os(macOS)
    @State private var isPresentingDatePopover: Bool = false
    @State private var showTimeZoneChoicePopover: Bool = false
#endif
    
    var body: some View {
        VStack {
            HStack {
                Text("TIME").fontWeight(.semibold)
                Spacer()
                
#if os(macOS)
                Button {
                    isPresentingDatePopover = true
                } label: {
                    Text("\(selectedDate, style: .date)").foregroundColor(.primary)
                }
                .popover(isPresented: $isPresentingDatePopover, arrowEdge: .top) {
                    Group {
                        MacDatePicker(selectedDate: $selectedDate)
                            .padding(8)
                    }.background(Color(NSColor.controlColor))
                }
                
                DatePicker("", selection: $selectedDate, displayedComponents: [.hourAndMinute])
                    .frame(maxWidth: 100)
                    .padding(.trailing)
                
#else
                DatePicker("TIME", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .labelsHidden()
#endif
                Button(action: {
                    withAnimation {
                        selectedDate = Date()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
#if os(iOS)
                .hoverEffect()
#endif
            }
            HStack {
                Text(multipleTimeZones ? "TIME_ZONE_PLURAL" : "TIME_ZONE").fontWeight(.semibold)
                Spacer()
                Button(action: {
#if os(macOS)
                    showTimeZoneChoicePopover = true
#else
                    showTimeZoneChoiceSheet = true
#endif
                }) {
                    if multipleTimeZones {
                        Text("CHOOSE_TIME_ZONE_PLURAL")
                    } else {
                        Text(selectedTimeZone?.friendlyName ?? TimeZone.current.friendlyName)
                    }
                }
                .foregroundColor(.primary)
                .padding(.vertical, 8)
#if os(iOS)
                .padding(.horizontal, 10)
                .hoverEffect()
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(UIColor.systemGray5))
                )
#endif
                #if os(macOS)
                .popover(isPresented: $showTimeZoneChoicePopover, arrowEdge: .leading) {
                    TimezoneChoiceView(selectedTimeZone: $selectedTimeZone, selectedTimeZones: $selectedTimeZones, selectedDate: $selectedDate, selectMultiple: multipleTimeZones) {
                        showTimeZoneChoicePopover = false
                    }
                    .frame(minWidth: 300, minHeight: 300)
                }
                #endif
            }
        }
        .padding([.horizontal, .bottom])
        .padding(.top, 10)
#if os(iOS)
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
                    Text("DONE")
                }
                )
            }
        }
#endif
    }
    
}

struct DateTimeZoneSheet_Previews: PreviewProvider {
    static var previews: some View {
        DateTimeZoneSheet(selectedDate: .constant(Date()), selectedTimeZone: .constant(nil), selectedTimeZones: .constant([]), selectedTimeZoneGroup: .constant(nil), multipleTimeZones: true)
    }
}
