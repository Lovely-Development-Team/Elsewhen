//
//  DateTimeZonePicker.swift
//  DateTimeZonePicker
//
//  Created by Ben Cardy on 11/09/2021.
//

import SwiftUI

struct DateTimeZonePicker: View {
    // MARK: Parameters
    @Binding var selectedDate: Date
    @Binding var selectedTimeZone: TimeZone
    var showDate: Bool = true
    let maxWidth: CGFloat?
    
    // MARK: State
    @State private var showTimeZoneChoiceSheet: Bool = false
    @State private var showTimeZoneChoicePopover: Bool = false
    @State private var selectTimeZoneButtonMaxWidth: CGFloat?
    
#if os(macOS)
    static let timePickerStyle = DefaultDatePickerStyle()
#else
    static let timePickerStyle = GraphicalDatePickerStyle.graphical
#endif
    
#if os(macOS)
    static let frameMaxWidth: CGFloat = .infinity
#else
    static let frameMaxWidth: CGFloat = 390
#endif
    
#if os(macOS)
    @State private var isPresentingDatePopover = false
#endif
    
#if os(iOS)
    let mediumImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
#endif
    
    var body: some View {
        Group {
            
            if showDate {
#if os(macOS)
                VStack {
                    Button {
                        isPresentingDatePopover = true
                    } label: {
                        Text("\(selectedDate, style: .date)")
                    }
                    .roundedRectangle()
                    .popover(isPresented: $isPresentingDatePopover, arrowEdge: .top) {
                        Group {
                            MacDatePicker(selectedDate: $selectedDate)
                                .padding(8)
                        }.background(Color(NSColor.controlColor))
                    }
                    Spacer(minLength: 20)
                    DatePicker("", selection: $selectedDate, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(Self.timePickerStyle)
                        .frame(maxWidth: selectTimeZoneButtonMaxWidth)
                        .padding(.horizontal, 8)
                    Spacer(minLength: 20)
                }
                .padding(.top)
                // Need to figure out the "proper" way to remove the datepicker's padding,
                // 16 is just a fudge value that looks okay by-eye.
                .frame(maxWidth: maxWidth.map { $0 + 16 })
#else
                DatePicker("Date", selection: $selectedDate)
                    .datePickerStyle(.graphical)
                    .padding(.top)
#endif
            } else {
                HStack {
                    Text("Time")
                        .fontWeight(.semibold)
                    Spacer()
#if os(macOS)
                    DatePicker("Time", selection: $selectedDate, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(Self.timePickerStyle)
                        .frame(maxWidth: selectTimeZoneButtonMaxWidth)
#else
                    DatePicker("Time", selection: $selectedDate, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(Self.timePickerStyle)
                        .labelsHidden()
                    Button(action: {
#if os(iOS)
                        mediumImpactFeedbackGenerator.impactOccurred()
#endif
                        self.selectedDate = Date()
                        
                    }) {
                        Text("Now")
                    }
#endif
                }
            }
            
            HStack {
                Text("Time zone")
                    .fontWeight(.semibold)
                Spacer()
                SelectTimeZoneButton(selectedTimeZone: $selectedTimeZone) {
#if os(macOS)
                    showTimeZoneChoicePopover = true
#else
                    self.showTimeZoneChoiceSheet = true
#endif
                }
                .background(GeometryReader { geometry in
                    Color.clear.preference(
                        key: SelectTimeZoneButtonWidthPreferenceKey.self,
                        value: geometry.size.width
                    )
                })
                .onPreferenceChange(SelectTimeZoneButtonWidthPreferenceKey.self) {
                    selectTimeZoneButtonMaxWidth = $0
                }
                .popover(isPresented: $showTimeZoneChoicePopover, arrowEdge: .leading) {
                    TimezoneChoiceView(selectedTimeZone: $selectedTimeZone, selectedTimeZones: .constant([]), selectedDate: $selectedDate, selectMultiple: false) {
                        showTimeZoneChoicePopover = false
                    }
                    .frame(minWidth: 300, minHeight: 300)
                }
            }
            .padding(.bottom, 10)
            #if os(macOS)
            .frame(minWidth: 0, maxWidth: maxWidth)
            #else
            .padding(.horizontal, showDate ? 8 : 0)
            .frame(minWidth: 0, maxWidth: DeviceType.isPad() ? 390 : .infinity)
            #endif
            .sheet(isPresented: $showTimeZoneChoiceSheet) {
                NavigationView {
                    TimezoneChoiceView(selectedTimeZone: $selectedTimeZone, selectedTimeZones: .constant([]), selectedDate: $selectedDate, selectMultiple: false) {
                        showTimeZoneChoiceSheet = false
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private extension DateTimeZonePicker {
    struct SelectTimeZoneButtonWidthPreferenceKey: PreferenceKey {
        static let defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat,
                           nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}

struct DateTimeZonePicker_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DateTimeZonePicker(selectedDate: .constant(Date()), selectedTimeZone: .constant(TimeZone(identifier: "Europe/London")!), showDate: false, maxWidth: nil)
        }
    }
}
