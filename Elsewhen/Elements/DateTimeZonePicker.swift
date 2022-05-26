//
//  DateTimeZonePicker.swift
//  DateTimeZonePicker
//
//  Created by Ben Cardy on 11/09/2021.
//

import SwiftUI

struct DateTimeZonePicker: View {
    // MARK: Environment
    @Environment(\.isInPopover) private var isInPopover
    // MARK: Parameters
    @Binding var selectedDate: Date
    @Binding var selectedTimeZone: TimeZone?
    var showFullCalendar: Bool = true
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
    
#if !os(macOS)
private static let pickerStackSpacing: CGFloat = 20
#else
private static let pickerStackSpacing: CGFloat = 5
#endif
    
    @ViewBuilder
    var timeZoneButton: some View {
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
    
    var body: some View {
        Group {
            
            #if os(macOS)
            
            HStack {
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
                
                Spacer(minLength: 20)
                
                DatePicker("", selection: $selectedDate, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(Self.timePickerStyle)
                    .frame(maxWidth: selectTimeZoneButtonMaxWidth)
                    .padding(.horizontal, 8)
                
                if isInPopover {
                    Spacer(minLength: 20)
                    timeZoneButton
                }
                
            }
            .padding(isInPopover ? .bottom : .vertical)
            .frame(minWidth: 0, maxWidth: .infinity)
            
            #else
            
            if showFullCalendar {
                DatePicker("Date", selection: $selectedDate)
                    .datePickerStyle(.graphical)
                    .padding(.top)
            } else {
                HStack {
                    Text("Time")
                        .fontWeight(.semibold)
                    Spacer()
                    DatePicker("Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    Button(action: {
                        mediumImpactFeedbackGenerator.impactOccurred()
                        self.selectedDate = Date()
                        
                    }) {
                        Text("Now")
                    }
                }
            }
            
            #endif
            
            if !isInPopover {
            
                HStack {
                    Text("Time zone")
                        .fontWeight(.semibold)
                    Spacer()
                    timeZoneButton
                }
                .padding(.bottom, 10)
                .padding(.horizontal, showFullCalendar ? 8 : 0)
                .frame(minWidth: 0, maxWidth: DeviceType.isPad() || DeviceType.isMac() ? maxWidth.map { $0 + 16 } : .infinity)
                .sheet(isPresented: $showTimeZoneChoiceSheet) {
                    NavigationView {
                        TimezoneChoiceView(selectedTimeZone: $selectedTimeZone, selectedTimeZones: .constant([]), selectedDate: $selectedDate, selectMultiple: false) {
                            showTimeZoneChoiceSheet = false
                        }
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
            DateTimeZonePicker(selectedDate: .constant(Date()), selectedTimeZone: .constant(TimeZone(identifier: "Europe/London")!), showFullCalendar: false, maxWidth: nil)
        }
    }
}
