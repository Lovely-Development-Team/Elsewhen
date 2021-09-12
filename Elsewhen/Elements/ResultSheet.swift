//
//  ResultSheet.swift
//  ResultSheet
//
//  Created by David on 10/09/2021.
//

import SwiftUI
import MobileCoreServices

struct ResultSheet: View {
    // MARK: Parameters
    let selectedDate: Date
    let selectedTimeZone: TimeZone
    let discordFormat: String
    @Binding var showLocalTimeInstead: Bool
    @Binding var selectedFormatStyle: DateFormat
    
    
    //MARK: State
    @State private var showCopied: Bool = false
    #if os(iOS)
    @State private var selectionFeedbackGenerator: UISelectionFeedbackGenerator? = nil
    @State private var notificationFeedbackGenerator: UINotificationFeedbackGenerator? = nil
    #endif
    
    var body: some View {
        VStack {
            VStack {
                
                if !showLocalTimeInstead {
                    
                    Text(format(date: convertSelectedDate(from: selectedTimeZone, to: selectedTimeZone), in: selectedTimeZone, with: selectedFormatStyle.code))
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                } else {
                    
                    Text(format(date: convertSelectedDate(from: selectedTimeZone, to: TimeZone.current), in: TimeZone.current, with: selectedFormatStyle.code))
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                }
                
                if selectedTimeZone != TimeZone.current {
                    
                    Text(showLocalTimeInstead ? "for you (\(TimeZone.current.friendlyName))" : "in \(selectedTimeZone.friendlyName)")
                        .foregroundColor(.secondary)
                    
                }
                
            }
            .padding(5)
            .contextMenu {
                ForEach(dateFormats, id: \.self) { formatStyle in
                    Button(action: {
                        self.selectedFormatStyle = formatStyle
                    }) {
                        Label(formatStyle.name, systemImage: formatStyle.icon)
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
            
            Group {
                DiscordFormattedDate(text: discordFormat)
                
                Button(action: {
                    #if os(iOS)
                    notificationFeedbackGenerator = UINotificationFeedbackGenerator()
                    notificationFeedbackGenerator?.prepare()
                    #endif
                    UIPasteboard.general.setValue(self.discordFormat,
                                                  forPasteboardType: kUTTypePlainText as String)
                    withAnimation {
                        showCopied = true
                        #if os(iOS)
                        notificationFeedbackGenerator?.notificationOccurred(.success)
                        #endif
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            showCopied = false
                        }
                        #if os(iOS)
                        notificationFeedbackGenerator = nil
                        #endif
                    }
                }) {
                    Text(showCopied ? "Copied ✓" : "Copy Discord Code")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(Color.accentColor)
                )
                .padding(.bottom, 8)
                
                Text("Date and time representative of components only; may not match exact Discord formatting.")
                    .multilineTextAlignment(.center)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
            }
            .padding(.horizontal)
            
        }
        .padding(.vertical)
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(
            Color(UIColor.secondarySystemBackground)
                .shadow(radius: 5, x: 0, y: -5)
                .opacity(0.5)
        )
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
