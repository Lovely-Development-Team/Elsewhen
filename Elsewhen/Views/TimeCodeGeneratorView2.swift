//
//  TimeCodeGeneratorView2.swift
//  Elsewhen
//
//  Created by Ben Cardy on 18/06/2022.
//

import SwiftUI

struct TimeCodeGeneratorView2: View {
    
    @Binding var selectedDate: Date
    @State private var selectedTimeZone: TimeZone? = nil
    @State private var appendRelative: Bool = false
    
    @State private var showEasterEggSheet: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
//            Text("Time Codes")
//                .font(.largeTitle)
//                .frame(minWidth: 0, maxWidth: .infinity)
//                .background(Color(UIColor.systemBackground))
            Toggle("Include Relative Time", isOn: $appendRelative.animation())
                .tint(.accentColor)
                .padding()
                .background(Color(UIColor.systemBackground))
            ScrollView {
                ForEach(dateFormats, id: \.self) { dateFormat in
                    FormatChoiceButton(dateFormat: dateFormat, selectedDate: $selectedDate, appendRelative: $appendRelative, timeZone: $selectedTimeZone)
                        .padding(.horizontal)
                }
                FormatChoiceButton(dateFormat: relativeDateFormat, selectedDate: $selectedDate, appendRelative: .constant(false), timeZone: $selectedTimeZone)
                    .padding(.horizontal)
                NotRepresentativeWarning()
                    .padding()
                EasterEggButton {
                    showEasterEggSheet = true
                }
                .padding(.bottom)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(Color.systemBackground)
            DateTimeZoneSheet(selectedDate: $selectedDate, selectedTimeZone: $selectedTimeZone, selectedTimeZones: .constant([]), selectedTimeZoneGroup: .constant(nil), multipleTimeZones: false, saveButtonTapped: nil)
        }
        .background(Color.secondarySystemBackground)
        .sheet(isPresented: $showEasterEggSheet) {
            EasterEggView()
        }
    }
}

struct TimeCodeGeneratorView2_Previews: PreviewProvider {
    static var previews: some View {
        TimeCodeGeneratorView2(selectedDate: .constant(Date()))
    }
}
