//
//  TimeCodeGeneratorView.swift
//  TimeCodeGeneratorView
//
//  Created by Ben Cardy on 11/09/2021.
//

import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers
import Combine

/// Publisher to read keyboard changes.
protocol KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> { get }
}

extension KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },
            
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
}

struct TimeCodeGeneratorView: View, KeyboardReadable {
    
    @State private var selectedDate = Date()
    @State private var selectedTimeZone: TimeZone = TimeZone.current
    @State private var selectedFormatStyle: DateFormat = dateFormats[0]
    @State private var showLocalTimeInstead: Bool = false
    
    @State private var resultSheetMaxHeight: CGFloat?
    
    @State private var isKeyboardVisible = false
    
    private var discordFormat: String {
        let timeIntervalSince1970 = Int(convertSelectedDate(from: selectedTimeZone, to: TimeZone.current).timeIntervalSince1970)
        return "<t:\(timeIntervalSince1970):\(selectedFormatStyle.code.rawValue)>"
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                
                ScrollView(showsIndicators: true) {
                    DateTimeSelection(selectedFormatStyle: $selectedFormatStyle, selectedDate: $selectedDate, selectedTimeZone: $selectedTimeZone)
                        .padding(.bottom, (resultSheetMaxHeight ?? 0) / 2 + 20)
                }
                if !isKeyboardVisible {
                    ResultSheet(selectedDate: selectedDate, selectedTimeZone: selectedTimeZone, discordFormat: discordFormat, showLocalTimeInstead: $showLocalTimeInstead, selectedFormatStyle: $selectedFormatStyle)
                    .background(GeometryReader { geometry in
                        Color.clear.preference(
                            key: ResultSheetHeightPreferenceKey.self,
                            value: geometry.size.width
                        )
                    })
                    .onPreferenceChange(ResultSheetHeightPreferenceKey.self) {
                        resultSheetMaxHeight = $0
                    }
                
                }
            }
            .edgesIgnoringSafeArea(.horizontal)
            .navigationTitle("Discord Time Code Generator")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onChange(of: selectedTimeZone) { _ in
            showLocalTimeInstead = false
        }
        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
            if UIDevice.current.userInterfaceIdiom == .phone {
                isKeyboardVisible = newIsKeyboardVisible
            }
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

extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}


struct TimeCodeGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        TimeCodeGeneratorView()
    }
}
