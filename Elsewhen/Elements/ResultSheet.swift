//
//  ResultSheet.swift
//  ResultSheet
//
//  Created by David on 10/09/2021.
//

import SwiftUI
import UniformTypeIdentifiers

struct ResultSheet: View {
    // MARK: Parameters
    let selectedDate: Date
    let selectedTimeZone: TimeZone
    let discordFormat: String
    @Binding var appendRelative: Bool
    @Binding var showLocalTimeInstead: Bool
    @Binding var selectedFormatStyle: DateFormat
    
    
    //MARK: State
    @State private var showCopied: Bool = false
    #if os(iOS)
    @State private var selectionFeedbackGenerator: UISelectionFeedbackGenerator? = nil
    @State private var notificationFeedbackGenerator: UINotificationFeedbackGenerator? = nil
    #endif
    
    private func getDateFormat(date: Date, in timezone: TimeZone, with formatCode: FormatCode) -> String {
        var formatted = format(date: date, in: timezone, with: formatCode)
        if appendRelative && formatCode != .R {
            let relative = format(date: date, in: timezone, with: FormatCode.R)
            formatted = "\(formatted) (\(relative))"
        }
        return formatted
    }
    
    var body: some View {
        VStack {
            VStack {
                
                if !showLocalTimeInstead {
                    
                    Text(getDateFormat(date: convertSelectedDate(from: selectedTimeZone, to: selectedTimeZone), in: selectedTimeZone, with: selectedFormatStyle.code))
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .selectable()
                    
                } else {
                    
                    Text(getDateFormat(date: convertSelectedDate(from: selectedTimeZone, to: TimeZone.current), in: TimeZone.current, with: selectedFormatStyle.code))
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .selectable()
                    
                }
                
                if selectedTimeZone != TimeZone.current {
                    
                    Text(showLocalTimeInstead ? "for you (\(TimeZone.current.friendlyName))" : "in \(selectedTimeZone.friendlyName)")
                        .foregroundColor(.secondary)
                    
                }
                
            }
            .padding(5)
            .contextMenu {
                /* Closing of the context menu animates after a format is selected.
                 We need the bindings and delayed set so that animation has time to finish before the next one starts
                 */
                Picker("", selection: Binding(get: {
                    selectedFormatStyle
                }, set: { newFormatStyle in
                    DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(600))) {
                        selectedFormatStyle = newFormatStyle
                    }
                })) {
                    ForEach(dateFormats, id: \.self) { formatStyle in
                        FormatLabel(style: formatStyle)
                    }
                    FormatLabel(style: relativeDateFormat)
                }.pickerStyle(InlinePickerStyle())
                if selectedFormatStyle != relativeDateFormat {
                    Divider()
                    Toggle(isOn: Binding(get: {
                        appendRelative
                    }, set: { shouldAppend in
                        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(600))) {
                            appendRelative = shouldAppend
                        }
                    })) {
                        Label("Append \(relativeDateFormat.name)", systemImage: relativeDateFormat.icon)
                    }
                }
            }
            .onTapGesture {
                #if os(iOS)
                selectionFeedbackGenerator = UISelectionFeedbackGenerator()
                #endif
                withAnimation {
                    showLocalTimeInstead = true
                    #if os(iOS)
                    selectionFeedbackGenerator?.selectionChanged()
                    #endif
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        showLocalTimeInstead = false
                    }
                    #if os(iOS)
                    selectionFeedbackGenerator = nil
                    #endif
                }
            }
            
            HStack {
                #if !os(macOS)
                Image(systemName: "square.and.arrow.up").opacity(0).accessibility(hidden: true)
                #endif
                CopyButton(text: "Copy Discord Code", generateText: { self.discordFormat }, showCopied: $showCopied)
                #if !os(macOS)
                ShareButton(generateText: { self.discordFormat })
                #endif
            }
            .padding(.bottom, 8)
            .padding(.horizontal)
            
        }
        .padding(.vertical)
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(
            Color.secondarySystemBackground
                .cornerRadius(15)
                .shadow(color: Color.primary.opacity(0.3), radius: 5, x: 0, y: 0)
        )
        .padding()
    }
    
    func convertSelectedDate(from initialTimezone: TimeZone, to targetTimezone: TimeZone) -> Date {
        return convert(date: selectedDate, from: initialTimezone, to: targetTimezone)
    }
}

//struct ResultSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        ResultSheet()
//    }
//}
