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
    @Binding var appendRelative: Bool
    
#if os(iOS)
    let mediumImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
#endif
    
    @State private var dateFormatsMaxWidth: CGFloat?
    
    var body: some View {
        Group {
            
            DateTimeZonePicker(selectedDate: $selectedDate, selectedTimeZone: $selectedTimeZone, maxWidth: dateFormatsMaxWidth)
            
            HStack(spacing: 5) {
                ForEach(dateFormats, id: \.self) { formatStyle in
                    Button(action: {
                        if self.selectedFormatStyle == formatStyle && appendRelative {
                            self.selectedFormatStyle = relativeDateFormat
                        } else {
                            self.selectedFormatStyle = formatStyle
                        }
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
                Button(action: {
                    if self.selectedFormatStyle != relativeDateFormat {
                        self.appendRelative.toggle()
                    }
                }) {
                    Label(relativeDateFormat.name, systemImage: relativeDateFormat.icon)
                        .labelStyle(IconOnlyLabelStyle())
                        .foregroundColor(appendRelative && selectedFormatStyle != relativeDateFormat ? .secondary : .white)
                        .font(.title)
                        .frame(width: 50, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(appendRelative && selectedFormatStyle != relativeDateFormat ? Color.accentColor : Color.clear, lineWidth: 3)
                                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(appendRelative ? (selectedFormatStyle == relativeDateFormat ? Color.accentColor : Color(UIColor.secondarySystemBackground)) : .secondary))
                        )
                }.buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom, 10)
            .background(GeometryReader { geometry in
                Color.clear.preference(
                    key: DateFormatsWidthPreferenceKey.self,
                    value: geometry.size.width
                )
            })
            .onPreferenceChange(DateFormatsWidthPreferenceKey.self) {
                dateFormatsMaxWidth = $0
            }
            
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

private extension DateTimeSelection {
    struct DateFormatsWidthPreferenceKey: PreferenceKey {
        static let defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat,
                           nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}
