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
        if selectedFormatStyle == relativeDateFormat {
            return Color.accentColor
        } else {
            if appendRelative {
                return Color.secondarySystemBackground
            } else {
                return .secondary
            }
        }
    }
    
    #if !os(macOS)
    private static let buttonFrame: CGFloat = 50
    #else
    private static let buttonFrame: CGFloat = 40
    #endif
    
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
    
    private func switchToRelativeFormat() {
        #if os(iOS)
        mediumImpactFeedbackGenerator.impactOccurred()
        #endif
        self.selectedFormatStyle = relativeDateFormat
        self.appendRelative = false
    }
    
    private func toggleAppendRelativeFormat() {
        if self.selectedFormatStyle != relativeDateFormat {
            self.appendRelative.toggle()
        }
    }
    
    #if !os(macOS)
    private static let formatButtonStyle = DefaultButtonStyle()
    #else
    private static let formatButtonStyle = PlainButtonStyle()
    #endif
    
    #if !os(macOS)
    private static let landscapeLayoutPadding: CGFloat = 20
    #else
    private static let landscapeLayoutPadding: CGFloat = 5
    #endif
    
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
                                #if !os(macOS)
                                FormatStyleButton(formatStyle: formatStyle, isSelected: formatStyle == selectedFormatStyle, onTap: formatStyleTapped)
                                #else
                                FormatStyleButton(formatStyle: formatStyle, isSelected: formatStyle == selectedFormatStyle, onTap: formatStyleTapped)
                                    .padding(.bottom, 2)
                                #endif
                            }
                            
                            Divider()
                            
                            Button(action: {}) {
                                HStack {
                                    Label(relativeDateFormat.name, systemImage: relativeDateFormat.icon)
                                        .labelStyle(IconOnlyLabelStyle())
                                        .foregroundColor(appendRelative && selectedFormatStyle != relativeDateFormat ? .secondary : .white)
                                        .font(.title)
                                        .frame(width: Self.buttonFrame, height: Self.buttonFrame)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .strokeBorder(appendRelative && selectedFormatStyle != relativeDateFormat ? Color.accentColor : Color.clear, lineWidth: 3)
                                                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(relativeDateButtonBackground))
                                        )
                                    Text(relativeDateFormat.name)
                                        .foregroundColor(appendRelative || selectedFormatStyle == relativeDateFormat ? Color.accentColor : Color.secondary)
                                }
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .onTapGesture(perform: toggleAppendRelativeFormat)
                                .onLongPressGesture(perform: switchToRelativeFormat)
                            }
                            .buttonStyle(Self.formatButtonStyle)
                            
                        }
                        .padding(.horizontal, 30)
                        
                        ResultSheet(selectedDate: selectedDate, selectedTimeZone: selectedTimeZone, discordFormat: discordFormat(for: selectedDate, in: selectedTimeZone, with: selectedFormatStyle.code, appendRelative: appendRelative), appendRelative: appendRelative, showLocalTimeInstead: $showLocalTimeInstead, selectedFormatStyle: $selectedFormatStyle)
                            .padding(.top, 10)
                        
                        DiscordFormattedDate(text: discordFormat(for: selectedDate, in: selectedTimeZone, with: selectedFormatStyle.code, appendRelative: appendRelative))
                        
                    }
                    
                }
                .padding(Self.landscapeLayoutPadding)
                
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
                    Button(action: {}) {
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
                            .onTapGesture(perform: toggleAppendRelativeFormat)
                            .onLongPressGesture(perform: switchToRelativeFormat)
                    }
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

struct DateTimeSelection_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            #if !os(macOS)
            DateTimeSelection(selectedFormatStyle: .constant(relativeDateFormat), selectedDate: .constant(Date()), selectedTimeZone: .constant(TimeZone.init(identifier: "Europe/London")!), appendRelative: .constant(false), showLocalTimeInstead: .constant(false)).environmentObject(OrientationObserver.shared)
            #else
            DateTimeSelection(selectedFormatStyle: .constant(relativeDateFormat), selectedDate: .constant(Date()), selectedTimeZone: .constant(TimeZone.init(identifier: "Europe/London")!), appendRelative: .constant(false), showLocalTimeInstead: .constant(false))
            #endif
        }
    }
}
