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
    
    @State private var selectedTimeZones: [TimeZone] = [
//        TimeZone(identifier: "America/Los_Angeles")!,
//        TimeZone(identifier: "America/New_York")!,
//        TimeZone(identifier: "Europe/London")!,
//        TimeZone(identifier: "Europe/Budapest")!,
    ]
    
    @State private var showCopied: Bool = false
    
#if os(iOS)
    //    @State private var selectionFeedbackGenerator: UISelectionFeedbackGenerator? = nil
    @State private var notificationFeedbackGenerator: UINotificationFeedbackGenerator? = nil
#endif
    
    func selectedTimeInZone(_ zone: TimeZone) -> String {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .short
        df.timeZone = zone
        df.locale = Locale(identifier: "en/us")
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
    
    var body: some View {
        
        NavigationView {
            
            VStack(spacing: 0) {
                VStack {
                    
                    Group {
                        
                        DateTimeZonePicker(selectedDate: $selectedDate, selectedTimeZone: $selectedTimeZone, showDate: false)
                        
                    }
                    .padding(.horizontal, 8)
                    
                    NavigationLink(destination: TimezoneChoiceView(selectedTimeZone: .constant(TimeZone.current), selectedTimeZones: $selectedTimeZones, selectedDate: $selectedDate, selectMultiple: true)) {
                        Text("Choose Time Zones…")
                    }
                    .padding(.top)
                    
                    List {
                        ForEach(selectedTimeZones, id: \.self) { tz in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(tz.friendlyName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(tz.flag) \(selectedTimeInZone(tz))")
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
                        }
                        .onMove(perform: move)
                    }
                    .listStyle(PlainListStyle())
                    
                }
                
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
                    Text(showCopied ? "Copied ✓" : "Copy Times & Flags")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(Color.accentColor)
                )
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(
                    Color(UIColor.secondarySystemBackground)
                        .shadow(radius: 5, x: 0, y: -5)
                        .opacity(0.5)
                )
                
            }
            .navigationTitle("Myke Mode")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            selectedTimeZones = UserDefaults.standard.mykeModeTimeZones
        }
        .onChange(of: selectedTimeZones) { newValue in
            UserDefaults.standard.mykeModeTimeZones = newValue
        }
        
    }
    
    func move(from source: IndexSet, to destination: Int) {
        selectedTimeZones.move(fromOffsets: source, toOffset: destination)
    }
    
}

struct MykeMode_Previews: PreviewProvider {
    static var previews: some View {
        MykeMode()
    }
}
