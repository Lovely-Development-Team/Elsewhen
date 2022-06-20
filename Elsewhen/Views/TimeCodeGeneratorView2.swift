//
//  TimeCodeGeneratorView2.swift
//  Elsewhen
//
//  Created by Ben Cardy on 18/06/2022.
//

import SwiftUI

struct TimeCodeGeneratorView2: View, OrientationObserving {
    
    // MARK: Environment
    @Environment(\.dynamicTypeSize) var dynamicTypesSize
    @EnvironmentObject internal var orientationObserver: OrientationObserver
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // MARK: State
    @Binding var selectedDate: Date
    @State private var selectedTimeZone: TimeZone? = nil
    @State private var appendRelative: Bool = false
    @State private var showEasterEggSheet: Bool = false
    
    let gridBreakPoint: Int = 170
    
    var gridItems: [GridItem] {
        if isPadAndNotCompact {
            return Array.init(repeating: .init(.flexible(), alignment: .top), count: 3)
        }
        if dynamicTypesSize >= .xxLarge {
            return [GridItem(.flexible(), alignment: .top)]
        }
        return [GridItem(.adaptive(minimum: CGFloat(gridBreakPoint)), alignment: .top)]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVGrid(columns: gridItems, spacing: 0) {
                    ForEach(dateFormats, id: \.self) { dateFormat in
                        FormatChoiceButton(dateFormat: dateFormat, selectedDate: $selectedDate, appendRelative: $appendRelative, timeZone: $selectedTimeZone)
                            .padding(.bottom)
                    }
                    FormatChoiceButton(dateFormat: relativeDateFormat, selectedDate: $selectedDate, appendRelative: .constant(false), timeZone: $selectedTimeZone)
                        .padding(.bottom)
                }
                .padding(.top)
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
            .clipped()
            .background(Color.systemBackground)
            VStack {
                Toggle("Include Relative Time", isOn: $appendRelative.animation())
                    .tint(.accentColor)
                    .padding([.horizontal, .top])
                    .padding(.bottom, 10)
                Divider()
                    .padding(.horizontal)
                DateTimeZoneSheet(selectedDate: $selectedDate, selectedTimeZone: $selectedTimeZone, selectedTimeZones: .constant([]), selectedTimeZoneGroup: .constant(nil), multipleTimeZones: false)
            }
            .background(
                ZStack {
                    Rectangle().fill(Color(UIColor.systemBackground))
                    RoundedCorner(cornerRadius: 15, corners: [.topLeft, .topRight])
                        .fill(Color(UIColor.secondarySystemBackground))
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 0)
                }
            )
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
