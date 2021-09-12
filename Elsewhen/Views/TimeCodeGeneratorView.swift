//
//  TimeCodeGeneratorView.swift
//  TimeCodeGeneratorView
//
//  Created by Ben Cardy on 11/09/2021.
//

import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers

struct TimeCodeGeneratorView: View {
    
    @Binding var selectedDate: Date
    @Binding var selectedTimeZone: TimeZone
    @State private var selectedFormatStyle: DateFormat = dateFormats[0]
    @State private var showLocalTimeInstead: Bool = false
    
    private var discordFormat: String {
        let timeIntervalSince1970 = Int(convertSelectedDate(from: selectedTimeZone, to: TimeZone.current).timeIntervalSince1970)
        return "<t:\(timeIntervalSince1970):\(selectedFormatStyle.code.rawValue)>"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                ScrollView(showsIndicators: true) {
                    DateTimeSelection(selectedFormatStyle: $selectedFormatStyle, selectedDate: $selectedDate, selectedTimeZone: $selectedTimeZone)
                }
                
                ResultSheet(selectedDate: selectedDate, selectedTimeZone: selectedTimeZone, discordFormat: discordFormat, showLocalTimeInstead: $showLocalTimeInstead, selectedFormatStyle: $selectedFormatStyle)
                
            }
            .edgesIgnoringSafeArea(.horizontal)
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

struct TimeCodeGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        TimeCodeGeneratorView(selectedDate: .constant(Date()), selectedTimeZone: .constant(TimeZone(identifier: "Europe/London")!))
    }
}
