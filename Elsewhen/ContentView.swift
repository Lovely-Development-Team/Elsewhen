//
//  ContentView.swift
//  Elsewhen
//
//  Created by Ben Cardy on 04/09/2021.
//

import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers
import os.log

enum FormatCode: String {
    case f
    case F
    case D
    case t
    case T
    case R
}

struct DateFormat: Identifiable, Hashable {
    let icon: String
    let name: String
    let code: FormatCode
    
    var id: String { code.rawValue }
}

let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "times")

struct ContentView: View {
    
    @State private var selectedDate = Date()
    @State private var selectedFormatStyle: DateFormat = Self.dateFormats[0]
    @State private var selectedTimeZone: String = TimeZone.current.identifier
    @State private var showCopied: Bool = false
    @State private var showLocalTimeInstead: Bool = false
    
    static private let dateFormats: [DateFormat] = [
        DateFormat(icon: "calendar.badge.clock", name: "Full", code: .f),
        DateFormat(icon: "calendar.badge.plus", name: "Full with Day", code: .F),
        DateFormat(icon: "calendar", name: "Date only", code: .D),
        DateFormat(icon: "clock", name: "Time only", code: .t),
        DateFormat(icon: "clock.fill", name: "Time with seconds", code: .T),
        DateFormat(icon: "clock.arrow.2.circlepath", name: "Relative", code: .R),
    ]
    
    private func format(date: Date, in timezone: TimeZone) -> String {
        let dateFormatter = DateFormatter()
        switch selectedFormatStyle.code {
        case .f:
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
        case .F:
            dateFormatter.dateStyle = .full
            dateFormatter.timeStyle = .short
        case .D:
            dateFormatter.dateStyle = .long
        case .t:
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
        case .T:
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .medium
        case .R:
            let relativeFormatter = RelativeDateTimeFormatter()
            let convertedNow = convert(date: Date(), from: TimeZone.current, to: timezone)
            return relativeFormatter.localizedString(for: date, relativeTo: convertedNow)
        }
        return dateFormatter.string(from: date)
    }
    
    private var discordFormat: String {
        
        
        var timeIntervalSince1970 = Int(selectedDate.timeIntervalSince1970)
        
        if let tz = TimeZone(identifier: selectedTimeZone) {
            timeIntervalSince1970 = Int(convertSelectedDate(from: tz, to: TimeZone.current).timeIntervalSince1970)
        } else {
            logger.warning("\(selectedTimeZone, privacy: .public) is not a valid timezone identifier!")
        }
        
        return "<t:\(timeIntervalSince1970):\(selectedFormatStyle.code.rawValue)>"
    }
    
    private func formatTimeZoneName(_ zone: String) -> String {
        zone.replacingOccurrences(of: "_", with: " ")
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                ScrollView(showsIndicators: true) {
                    
                    Group {
                        
                        DatePicker("Date", selection: $selectedDate)
                            .datePickerStyle(.graphical)
                            .padding(.top)
                        
                        HStack {
                            Text("Time zone")
                                .fontWeight(.bold)
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
                        
                        HStack(spacing: 5) {
                            ForEach(Self.dateFormats, id: \.self) { formatStyle in
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
                
                VStack {
                    VStack {
                        
                        let selectedTimezoneIdentifier = TimeZone(identifier: selectedTimeZone)!
                        
                        if !showLocalTimeInstead {
                            
                            Text(format(date: convertSelectedDate(from: selectedTimezoneIdentifier, to: selectedTimezoneIdentifier), in: selectedTimezoneIdentifier))
                                .multilineTextAlignment(.center)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                        } else {
                            
                            Text(format(date: convertSelectedDate(from: selectedTimezoneIdentifier, to: TimeZone.current), in: TimeZone.current))
                                .multilineTextAlignment(.center)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                        }
                        
                        if selectedTimezoneIdentifier != TimeZone.current {
                            
                            Text(showLocalTimeInstead ? "for you (\(formatTimeZoneName(TimeZone.current.identifier)))" : "in \(formatTimeZoneName(selectedTimeZone))")
                                .foregroundColor(.secondary)
                            
                        }
                        
                    }
                    .padding(5)
                    .contextMenu {
                        ForEach(Self.dateFormats, id: \.self) { formatStyle in
                            Button(action: {
                                self.selectedFormatStyle = formatStyle
                            }) {
                                Label(formatStyle.name, systemImage: formatStyle.icon)
                            }
                        }
                    }
                    .onTapGesture {
                        withAnimation {
                            showLocalTimeInstead = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showLocalTimeInstead = false
                            }
                        }
                    }
                    
                    Group {
                        
                        DiscordFormattedDate(text: discordFormat)
                        
                        Button(action: {
                            UIPasteboard.general.setValue(self.discordFormat,
                                                          forPasteboardType: kUTTypePlainText as String)
                            withAnimation {
                                showCopied = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation {
                                    showCopied = false
                                }
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
                        .shadow(radius: 10)
                )
                
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationTitle("Discord Time Code Generator")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func convertSelectedDate(from initialTimezone: TimeZone, to targetTimezone: TimeZone) -> Date {
        return convert(date: selectedDate, from: initialTimezone, to: targetTimezone)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

func convert(date: Date, from initialTimezone: TimeZone, to targetTimezone: TimeZone) -> Date {
    let offset = TimeInterval(targetTimezone.secondsFromGMT(for: date) - initialTimezone.secondsFromGMT(for: date))
    return date.addingTimeInterval(offset)
}