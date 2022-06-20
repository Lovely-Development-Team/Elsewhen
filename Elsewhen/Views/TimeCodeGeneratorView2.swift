//
//  TimeCodeGeneratorView2.swift
//  Elsewhen
//
//  Created by Ben Cardy on 18/06/2022.
//

import SwiftUI

struct TimeCodeGeneratorView2: View {
    
    // MARK: Environment
    @Environment(\.dynamicTypeSize) var dynamicTypesSize
    
    // MARK: State
    @Binding var selectedDate: Date
    @State private var selectedTimeZone: TimeZone? = nil
    @State private var appendRelative: Bool = true
    @State private var showEasterEggSheet: Bool = false
    
    let gridBreakPoint: Int = 170
    
    var gridItems: [GridItem] {
        if dynamicTypesSize >= .xxLarge {
            return [GridItem(.flexible(), alignment: .top)]
        }
        return [GridItem(.adaptive(minimum: CGFloat(gridBreakPoint)), alignment: .top)]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Toggle("Include Relative Time", isOn: $appendRelative.animation())
                .tint(.accentColor)
                .padding()
                .background(Color(UIColor.systemBackground))
            ScrollView {
                LazyVGrid(columns: gridItems, spacing: 0) {
                    ForEach(dateFormats, id: \.self) { dateFormat in
                        FormatChoiceButton(dateFormat: dateFormat, selectedDate: $selectedDate, appendRelative: $appendRelative, timeZone: $selectedTimeZone)
                            .padding(.bottom)
                    }
                    FormatChoiceButton(dateFormat: relativeDateFormat, selectedDate: $selectedDate, appendRelative: .constant(false), timeZone: $selectedTimeZone)
                        .padding(.bottom)
                }
                .fixedSize(horizontal: false, vertical: true)
                NotRepresentativeWarning()
                    .padding([.horizontal, .bottom])
                EasterEggButton {
                    showEasterEggSheet = true
                }
                .padding(.bottom)
            }
            .padding(.horizontal)
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
