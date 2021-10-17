//
//  DateTimeSelection.swift
//  DateTimeSelection
//
//  Created by David on 10/09/2021.
//

import SwiftUI

struct DateTimeSelection: View, OrientationObserving {
    
    #if !os(macOS)
    @EnvironmentObject internal var orientationObserver: OrientationObserver
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    #endif
    
    @Binding var selectedFormatStyle: DateFormat
    @Binding var selectedDate: Date
    @Binding var selectedTimeZone: TimeZone
    @Binding var appendRelative: Bool
    @Binding var showLocalTimeInstead: Bool
    
#if os(iOS)
    let mediumImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
#endif
    
    @State private var dateFormatsMaxWidth: CGFloat?
    
    var relativeDateButtonBackground: Color {
        guard appendRelative else {
            return .secondary
        }
        if selectedFormatStyle == relativeDateFormat {
            return Color.accentColor
        } else {
            return Color.secondarySystemBackground
        }
    }
    
    @ViewBuilder
    private func formatStyleButton(for formatStyle: DateFormat) -> some View {
        Label(formatStyle.name, systemImage: formatStyle.icon)
            .labelStyle(IconOnlyLabelStyle())
            .foregroundColor(.white)
            .font(.title)
            .frame(width: 50, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(formatStyle == selectedFormatStyle ? Color.accentColor : .secondary)
            )
    }
    
    private func formatStyleTapped(_ formatStyle: DateFormat) {
        if selectedFormatStyle == formatStyle && appendRelative {
            selectedFormatStyle = relativeDateFormat
        } else {
            selectedFormatStyle = formatStyle
        }
    }
    
    private func reset() {
#if os(iOS)
            mediumImpactFeedbackGenerator.impactOccurred()
#endif
            self.selectedDate = Date()
            self.selectedTimeZone = TimeZone.current
        
    }
    
    var body: some View {
        Group {
            
            if isOrientationLandscape && isRegularHorizontalSize {
                
                HStack(alignment: .top, spacing: 20) {
                    
                    VStack {
                        
                        DateTimeZonePicker(selectedDate: $selectedDate, selectedTimeZone: $selectedTimeZone, maxWidth: 376)
                            .offset(x: 0, y: -20)
                        
                        Button(action: reset) {
                            Text("Reset")
                        }
                        
                    }
                    
                    VStack {
                        
                        VStack(alignment: .leading) {
                        
                            ForEach(dateFormats, id: \.self) { formatStyle in
                                Button(action: {
                                    formatStyleTapped(formatStyle)
                                }) {
                                    HStack {
                                        formatStyleButton(for: formatStyle)
                                        Text(formatStyle.name)
                                            .foregroundColor(formatStyle == selectedFormatStyle ? Color.accentColor : .secondary)
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            
                            Divider()
                            
                            Button(action: {
                                if self.selectedFormatStyle != relativeDateFormat {
                                    self.appendRelative.toggle()
                                }
                            }) {
                                HStack {
                                    Label(relativeDateFormat.name, systemImage: relativeDateFormat.icon)
                                        .labelStyle(IconOnlyLabelStyle())
                                        .foregroundColor(appendRelative && selectedFormatStyle != relativeDateFormat ? .secondary : .white)
                                        .font(.title)
                                        .frame(width: 50, height: 50)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .strokeBorder(appendRelative && selectedFormatStyle != relativeDateFormat ? Color.accentColor : Color.clear, lineWidth: 3)
                                                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(relativeDateButtonBackground))
                                        )
                                    Text(relativeDateFormat.name)
                                        .foregroundColor(appendRelative || selectedFormatStyle == relativeDateFormat ? Color.accentColor : Color.secondary)
                                }
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            }
                            
                        }
                        .padding(.horizontal, 30)
                        
                        ResultSheet(selectedDate: selectedDate, selectedTimeZone: selectedTimeZone, discordFormat: discordFormat(for: selectedDate, in: selectedTimeZone, with: selectedFormatStyle.code, appendRelative: appendRelative), appendRelative: appendRelative, showLocalTimeInstead: $showLocalTimeInstead, selectedFormatStyle: $selectedFormatStyle)
                            .padding(.top, 10)
                        
                        DiscordFormattedDate(text: discordFormat(for: selectedDate, in: selectedTimeZone, with: selectedFormatStyle.code, appendRelative: appendRelative))
                        
                    }
                    
                }
                .padding(20)
                
            } else {
            
                DateTimeZonePicker(selectedDate: $selectedDate, selectedTimeZone: $selectedTimeZone, maxWidth: dateFormatsMaxWidth)
                
                HStack(spacing: 5) {
                    ForEach(dateFormats, id: \.self) { formatStyle in
                        Button(action: {
                            formatStyleTapped(formatStyle)
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
                                    .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(relativeDateButtonBackground))
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
                
                Button(action: reset) {
                    Text("Reset")
                }
                .padding(.bottom, 20)
                
            }
            
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
