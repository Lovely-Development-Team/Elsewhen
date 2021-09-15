//
//  MykeMode.swift
//  MykeMode
//
//  Created by Ben Cardy on 11/09/2021.
//

import SwiftUI
import UniformTypeIdentifiers

struct MykeMode: View {
    
    @State private var selectedDate = Date()
    @State private var selectedTimeZone: TimeZone = TimeZone.current
    
    @State private var selectedFormatStyle: DateFormat = dateFormats[0]
    
    @State private var selectedTimeZones: [TimeZone] = []
    @State private var timeZonesUsingEUFlag: Set<TimeZone> = []
    
    @State private var showCopied: Bool = false
    
#if os(iOS)
    @State private var notificationFeedbackGenerator: UINotificationFeedbackGenerator? = nil
    let mediumImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
#endif
    
    @State private var showTimeZoneSheet: Bool = false
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
                        
                        Button(action: {
                            self.showTimeZoneSheet = true
                        }) {
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
                                                          forPasteboardType: UTType.utf8PlainText.identifier)
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
                        )
                        
                    }
                    .padding(.horizontal, 8)
                    
                }
                .padding(.horizontal, 8)
                .frame(minWidth: 0, maxWidth: 390)
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
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if tz.isMemberOfEuropeanUnion {
#if os(iOS)
                                mediumImpactFeedbackGenerator.impactOccurred()
#endif
                                if timeZonesUsingEUFlag.contains(tz) {
                                    timeZonesUsingEUFlag.remove(tz)
                                } else {
                                    timeZonesUsingEUFlag.insert(tz)
                                }
                            }
                        }
                    }
                    .onMove(perform: move)
                    .onDelete(perform: delete)
                }
                .listStyle(PlainListStyle())
                .padding(.top, (buttonMaxHeight ?? 0) / 2)
            }
            .navigationTitle("Time List")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showTimeZoneSheet) {
            NavigationView {
                TimezoneChoiceView(selectedTimeZone: .constant(TimeZone.current), selectedTimeZones: $selectedTimeZones, selectedDate: $selectedDate, selectMultiple: true)
                    .navigationBarItems(trailing:
                                            Button(action: {
                        self.showTimeZoneSheet = false
                    }) {
                        Text("Done")
                    }
                    )
            }
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
    
    func delete(at offsets: IndexSet) {
        selectedTimeZones.remove(atOffsets: offsets)
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
