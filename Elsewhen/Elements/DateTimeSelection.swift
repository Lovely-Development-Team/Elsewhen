//
//  DateTimeSelection.swift
//  DateTimeSelection
//
//  Created by David on 10/09/2021.
//

import SwiftUI

struct DateTimeSelection: View {
    @Binding var selectedFormatStyle: DateFormat
    @Binding var selectedDate: Date
    @Binding var selectedTimeZone: String
    
    var body: some View {
        Group {
            
            DatePicker("Date", selection: $selectedDate)
                .datePickerStyle(.graphical)
                .padding(.top)
            
            HStack {
                Text("Time zone")
                    .fontWeight(.semibold)
                Spacer()
                NavigationLink(destination: TimezoneChoiceView(selectedTimeZone: $selectedTimeZone)) {
                    Text(selectedTimeZone.replacingOccurrences(of: "_", with: " "))
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 10)
            .frame(minWidth: 0, maxWidth: 390)
            
            HStack(spacing: 5) {
                ForEach(dateFormats, id: \.self) { formatStyle in
                    Button(action: {
                        self.selectedFormatStyle = formatStyle
                    }) {
                        Label(formatStyle.name, systemImage: formatStyle.icon)
                            .labelStyle(IconOnlyLabelStyle())
                            .foregroundColor(.white)
                            .font(.title)
                            .frame(width: 50, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(formatStyle == selectedFormatStyle ? Color.accentColor : .secondary)
                            )
                    }.buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.bottom, 10)
            
            Button(action: {
                self.selectedDate = Date()
                self.selectedTimeZone = TimeZone.current.identifier
            }) {
                Text("Reset")
            }
            .padding(.bottom, 20)
            
        }
        .padding(.horizontal)
    }
}
