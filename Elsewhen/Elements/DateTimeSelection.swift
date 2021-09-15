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
    @Binding var selectedTimeZone: TimeZone
    
#if os(iOS)
    let mediumImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
#endif
    
    var body: some View {
        Group {
            
            DateTimeZonePicker(selectedDate: $selectedDate, selectedTimeZone: $selectedTimeZone)
            
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
#if os(iOS)
                mediumImpactFeedbackGenerator.impactOccurred()
#endif
                self.selectedDate = Date()
                self.selectedTimeZone = TimeZone.current
            }) {
                Text("Reset")
            }
            .padding(.bottom, 20)
            
        }
        .padding(.horizontal)
    }
}
