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
    @State private var showResultsSheet = false
    @State private var resultsSheetOffset = 20.0
    @State private var showEasterEggSheet = false
    
    private var discordFormat: String {
        let timeIntervalSince1970 = Int(convertSelectedDate(from: selectedTimeZone, to: TimeZone.current).timeIntervalSince1970)
        return "<t:\(timeIntervalSince1970):\(selectedFormatStyle.code.rawValue)>"
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            ScrollView {
                
                DateTimeSelection(selectedFormatStyle: $selectedFormatStyle, selectedDate: $selectedDate, selectedTimeZone: $selectedTimeZone)
                
                VStack(spacing: 0) {
                
                    DiscordFormattedDate(text: discordFormat)
                        .padding(.bottom, 8)
                    
                    Text("Date and time representative of components only; may not match exact Discord formatting.")
                        .multilineTextAlignment(.center)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    
                    Button(action: {
                        showEasterEggSheet = true
                    }, label: {
                        HStack {
                            Text("From the Lovely Developers")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Image("l2culogosvg")
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.secondary)
                                .frame(height: 15)
                                .accessibility(hidden: true)
                                
                        }
                    })
                        .buttonStyle(PlainButtonStyle())
                        .padding(.vertical, 5)
                    
                }
                .padding(.horizontal)
                .padding(.bottom, (resultSheetMaxHeight ?? 0) / 2)
                
            }
            if !isKeyboardVisible {
                ResultSheet(selectedDate: selectedDate, selectedTimeZone: selectedTimeZone, discordFormat: discordFormat, showLocalTimeInstead: $showLocalTimeInstead, selectedFormatStyle: $selectedFormatStyle)
                    .opacity(showResultsSheet ? 1 : 0)
                    .background(GeometryReader { geometry in
                        Color.clear.preference(
                            key: ResultSheetHeightPreferenceKey.self,
                            value: geometry.size.width
                        )
                    })
                    .onPreferenceChange(ResultSheetHeightPreferenceKey.self) {
                        resultSheetMaxHeight = $0
                    }
                    .offset(x: 0.0, y: resultsSheetOffset)
            }
        }
        .onChange(of: selectedTimeZone) { _ in
            showLocalTimeInstead = false
        }
        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
            if UIDevice.current.userInterfaceIdiom == .phone {
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
        TimeCodeGeneratorView()
    }
}
