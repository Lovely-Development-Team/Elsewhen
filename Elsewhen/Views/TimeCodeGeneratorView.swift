//
//  TimeCodeGeneratorView.swift
//  TimeCodeGeneratorView
//
//  Created by Ben Cardy on 11/09/2021.
//

import SwiftUI
import UniformTypeIdentifiers

struct TimeCodeGeneratorView: View, KeyboardReadable, OrientationObserving {
    
    #if !os(macOS)
    @EnvironmentObject internal var orientationObserver: OrientationObserver
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    
    @State private var selectedDate = Date()
    @State private var selectedTimeZone: TimeZone = TimeZone.current
    @State private var selectedFormatStyle: DateFormat = dateFormats[0]
    @State private var showLocalTimeInstead: Bool = false
    @State private var appendRelative: Bool = false
    
    @State private var resultSheetMaxHeight: CGFloat?
    
    @State private var isKeyboardVisible = false
    @State private var showResultsSheet = false
    @State private var resultsSheetOffset = 20.0
    @State private var showEasterEggSheet = false
    
    private var discordFormatString: String {
        return discordFormat(for: selectedDate, in: selectedTimeZone, with: selectedFormatStyle.code, appendRelative: appendRelative)
    }
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            if isOrientationLandscape && isRegularHorizontalSize {
                
                VStack {
                                    
                    DateTimeSelection(selectedFormatStyle: $selectedFormatStyle, selectedDate: $selectedDate, selectedTimeZone: $selectedTimeZone, appendRelative: $appendRelative, showLocalTimeInstead: $showLocalTimeInstead)
                        .padding(.top, 30)
                    
                    Spacer()
                    
                    HStack {
                        Text("Date and time representative of components only; may not match exact Discord formatting.")
                            .multilineTextAlignment(.center)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        EasterEggButton {
                            showEasterEggSheet = true
                        }
                    }
                    .padding(.bottom, 20)
                    
                }
                
            } else {
            
                VStack(spacing: 0) {
                    Rectangle().fill(Color.clear).frame(height: 1)
                    ScrollView {
                        
                        DateTimeSelection(selectedFormatStyle: $selectedFormatStyle, selectedDate: $selectedDate, selectedTimeZone: $selectedTimeZone, appendRelative: $appendRelative, showLocalTimeInstead: $showLocalTimeInstead)
                        
                        VStack(spacing: 0) {
                            
                            DiscordFormattedDate(text: discordFormatString)
                                .padding(.bottom, 8)
                            
                            Text("Date and time representative of components only; may not match exact Discord formatting.")
                                .multilineTextAlignment(.center)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                                .padding(.bottom, 20)
                            
                            EasterEggButton {
                                showEasterEggSheet = true
                            }
                            .padding(.vertical, 5)
                            
                        }
                        .padding(.horizontal)
                        .padding(.bottom, (resultSheetMaxHeight ?? 0))
                        
                    }
                }
                
            }
            
            if !isKeyboardVisible && (isOrientationPortrait || isCompactHorizontalSize) {
                ResultSheet(selectedDate: selectedDate, selectedTimeZone: selectedTimeZone, discordFormat: discordFormatString, appendRelative: appendRelative, showLocalTimeInstead: $showLocalTimeInstead, selectedFormatStyle: $selectedFormatStyle)
                    .opacity(showResultsSheet ? 1 : 0)
                    .background(GeometryReader { geometry in
                        Color.clear.preference(
                            key: ResultSheetHeightPreferenceKey.self,
                            value: geometry.size.height
                        )
                    })
                    .onPreferenceChange(ResultSheetHeightPreferenceKey.self) {
                        resultSheetMaxHeight = $0
                    }
                    .offset(x: 0.0, y: resultsSheetOffset)
                    .padding(.horizontal)
            }
            
        }
        .onChange(of: selectedTimeZone) { _ in
            showLocalTimeInstead = false
        }
        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
            if DeviceType.isPhone() {
                isKeyboardVisible = newIsKeyboardVisible
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    self.showResultsSheet = true
                    self.resultsSheetOffset = 0.0
                }
            }
        }
        .sheet(isPresented: $showEasterEggSheet) {
            EasterEggView()
        }
    }
    
    func convertSelectedDate(from initialTimezone: TimeZone, to targetTimezone: TimeZone) -> Date {
        return convert(date: selectedDate, from: initialTimezone, to: targetTimezone)
    }
}

private extension TimeCodeGeneratorView {
    struct ResultSheetHeightPreferenceKey: PreferenceKey {
        static let defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat,
                           nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}

struct TimeCodeGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        #if !os(macOS)
        if #available(iOS 15.0, *) {
            TimeCodeGeneratorView().previewInterfaceOrientation(.landscapeLeft)
        } else {
            TimeCodeGeneratorView()
        }
        #else
        TimeCodeGeneratorView()
        #endif
    }
}
