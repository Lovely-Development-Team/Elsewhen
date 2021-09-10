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
    @State private var selectedFormatStyle: DateFormat = dateFormats[0]
    @State private var selectedTimeZone: String = TimeZone.current.identifier
    @State private var showLocalTimeInstead: Bool = false
    
    private var discordFormat: String {
        var timeIntervalSince1970 = Int(selectedDate.timeIntervalSince1970)
        
        if let tz = TimeZone(identifier: selectedTimeZone) {
            timeIntervalSince1970 = Int(convertSelectedDate(from: tz, to: TimeZone.current).timeIntervalSince1970)
        } else {
            logger.warning("\(selectedTimeZone, privacy: .public) is not a valid timezone identifier!")
        }
        
        return "<t:\(timeIntervalSince1970):\(selectedFormatStyle.code.rawValue)>"
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
                
                ResultSheet(selectedDate: selectedDate, selectedTimeZone: selectedTimeZone, discordFormat: discordFormat, showLocalTimeInstead: $showLocalTimeInstead, selectedFormatStyle: $selectedFormatStyle)
                
            }
            .edgesIgnoringSafeArea([.bottom, .horizontal])
            .navigationTitle("Discord Time Code Generator")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onChange(of: selectedTimeZone) { _ in
            showLocalTimeInstead = false
        }
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
