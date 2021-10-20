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
    @Environment(\.isInPopover) var isInPopover
    
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
                        #if !os(macOS)
                        .padding(.top, 30)
                        #endif
                        .accessibilitySortPriority(2)
                    
                        Spacer()
                    
                    Group {
                        if DeviceType.isMac() && isInPopover {
                            VStack {
                                NotRepresentativeWarning()
                                
                                EasterEggButton {
                                    showEasterEggSheet = true
                                }
                            }
                        } else {
                            HStack {
                                NotRepresentativeWarning()
                                
                                EasterEggButton {
                                    showEasterEggSheet = true
                                }
                            }
                        }
                    }
                    .padding(.bottom, 20)
                    .accessibilitySortPriority(0)
                }
                .accessibilitySortPriority(2)
                
            } else {
            
                VStack(spacing: 0) {
                    Rectangle().fill(Color.clear).frame(height: 1)
                    ScrollView {
                        
                        DateTimeSelection(selectedFormatStyle: $selectedFormatStyle, selectedDate: $selectedDate, selectedTimeZone: $selectedTimeZone, appendRelative: $appendRelative, showLocalTimeInstead: $showLocalTimeInstead)
                            .accessibilitySortPriority(2)
                        
                        VStack(spacing: 0) {
                            
                            DiscordFormattedDate(text: discordFormatString)
                                .padding(.bottom, 8)
                            
                            NotRepresentativeWarning()
                                .padding(.bottom, 20)
                            
                            EasterEggButton {
                                showEasterEggSheet = true
                            }
                            .padding(.vertical, 5)
                            
                        }
                        .padding(.horizontal)
                        .padding(.bottom, (resultSheetMaxHeight ?? 0))
                        .accessibilitySortPriority(0)
                        
                    }
                }
                .accessibilitySortPriority(2)
                
            }
            
            if !isKeyboardVisible && (isOrientationPortrait || isCompactHorizontalSize) {
                ResultSheet(selectedDate: selectedDate, selectedTimeZone: selectedTimeZone, discordFormat: discordFormatString, appendRelative: $appendRelative, showLocalTimeInstead: $showLocalTimeInstead, selectedFormatStyle: $selectedFormatStyle)
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
                    .accessibilitySortPriority(1)
            }
            
        }
        .accessibilityElement(children: .contain)
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
            TimeCodeGeneratorView().environmentObject(OrientationObserver.shared)//.previewInterfaceOrientation(.landscapeLeft)
        } else {
            TimeCodeGeneratorView()
        }
        #else
        TimeCodeGeneratorView()
        #endif
    }
}
