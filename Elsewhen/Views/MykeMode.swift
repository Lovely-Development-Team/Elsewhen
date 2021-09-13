//
//  MykeMode.swift
//  MykeMode
//
//  Created by Ben Cardy on 11/09/2021.
//

import SwiftUI
import MobileCoreServices

struct MykeMode: View {
    
    @State private var selectedDate = Date()
    @State private var selectedTimeZone: TimeZone = TimeZone.current
    
    @State private var selectedFormatStyle: DateFormat = dateFormats[0]
    
    @State private var selectedTimeZones: [TimeZone] = []
    @State private var timeZonesUsingEUFlag: Set<TimeZone> = []
    
    @State private var showCopied: Bool = false
    
#if os(iOS)
    @State private var notificationFeedbackGenerator: UINotificationFeedbackGenerator? = nil
#endif
    
    @State private var buttonMaxHeight: CGFloat?
    
    func selectedTimeInZone(_ zone: TimeZone) -> String {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .short
        df.timeZone = zone
        return df.string(from: convert(date: selectedDate, from: selectedTimeZone, to: TimeZone.current))
    }
    
    func generateTimesAndFlagsText() -> String {
        var text = "\n"
        for tz in selectedTimeZones {
            let abbr = tz.fudgedAbbreviation(for: selectedDate) ?? ""
            text += "\(flagForTimeZone(tz)) - \(selectedTimeInZone(tz)) \(abbr)\n"
        }
        return text
    }
    
    func flagForTimeZone(_ tz: TimeZone) -> String {
        if timeZonesUsingEUFlag.contains(tz) {
            return "🇪🇺"
        }
        return tz.flag
    }
    
    var body: some View {
        
        NavigationView {
            
            ZStack(alignment: .top) {
                
                VStack {
                    DateTimeZonePicker(selectedDate: $selectedDate, selectedTimeZone: $selectedTimeZone, showDate: false)
                    
                    HStack {
                        
                        NavigationLink(destination: TimezoneChoiceView(selectedTimeZone: .constant(TimeZone.current), selectedTimeZones: $selectedTimeZones, selectedDate: $selectedDate, selectMultiple: true)) {
                            Text("Choose time zones…")
                        }
                        .padding(.vertical)
                        
                        Spacer()
                        
                        Button(action: {
#if os(iOS)
                            notificationFeedbackGenerator = UINotificationFeedbackGenerator()
                            notificationFeedbackGenerator?.prepare()
#endif
                            UIPasteboard.general.setValue(generateTimesAndFlagsText(),
                                                          forPasteboardType: kUTTypePlainText as String)
                            withAnimation {
                                showCopied = true
#if os(iOS)
                                notificationFeedbackGenerator?.notificationOccurred(.success)
#endif
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation {
                                    showCopied = false
                                }
#if os(iOS)
                                notificationFeedbackGenerator = nil
#endif
                            }
                        }) {
                            Text(showCopied ? "Copied ✓" : "Copy")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(Color.accentColor)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 0)
                        )
                        
                    }
                    .padding(.horizontal, 8)
                    
                }
                .padding(.horizontal, 8)
                .background(GeometryReader { geometry in
                    Color.clear.preference(
                        key: ButtonHeightPreferenceKey.self,
                        value: geometry.size.width
                    )
                })
                .onPreferenceChange(ButtonHeightPreferenceKey.self) {
                    buttonMaxHeight = $0
                }
                
                List {
                    ForEach(selectedTimeZones, id: \.self) { tz in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(tz.friendlyName)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(flagForTimeZone(tz)) \(selectedTimeInZone(tz))")
                            }
                            Spacer()
                            if let abbreviation = tz.fudgedAbbreviation(for: selectedDate) {
                                Text(abbreviation)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onDrag {
                            let tzItemProvider = tz.itemProvider
                            let itemProvider = NSItemProvider(object: tzItemProvider)
                            itemProvider.suggestedName = tzItemProvider.resolvedName
                            return itemProvider
                        }
                        .contextMenu {
                            if tz.identifier.starts(with: "Europe/") {
                                Button(action: {
                                    timeZonesUsingEUFlag.remove(tz)
                                }) {
                                    Label("Use country flag", systemImage: "flag")
                                }
                                Button(action: {
                                    timeZonesUsingEUFlag.insert(tz)
                                }) {
                                    Label("Use European Union flag", systemImage: "flag.fill")
                                }
                            }
                        }
                    }
                    .onMove(perform: move)
                }
                .listStyle(PlainListStyle())
                .padding(.top, (buttonMaxHeight ?? 0) / 2)
            }
            .navigationTitle("Myke Mode")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            selectedTimeZones = UserDefaults.standard.mykeModeTimeZones
            timeZonesUsingEUFlag = UserDefaults.standard.mykeModeTimeZonesUsingEUFlag
        }
        .onChange(of: selectedTimeZones) { newValue in
            UserDefaults.standard.mykeModeTimeZones = newValue
        }
        .onChange(of: timeZonesUsingEUFlag) { newValue in
            UserDefaults.standard.mykeModeTimeZonesUsingEUFlag = newValue
        }
        
    }
    
    func move(from source: IndexSet, to destination: Int) {
        selectedTimeZones.move(fromOffsets: source, toOffset: destination)
    }
    
}

private extension MykeMode {
    struct ButtonHeightPreferenceKey: PreferenceKey {
        static let defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat,
                           nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}

struct MykeMode_Previews: PreviewProvider {
    static var previews: some View {
        MykeMode()
    }
}
