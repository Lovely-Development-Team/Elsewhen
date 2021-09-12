//
//  MykeMode.swift
//  MykeMode
//
//  Created by Ben Cardy on 11/09/2021.
//

import SwiftUI
import MobileCoreServices

struct MykeMode: View {
    
    //    @State private var selectedDate: Date = Date(timeIntervalSince1970: TimeInterval(1639239835))
    //    @State private var selectedDate: Date = Date(timeIntervalSince1970: TimeInterval(1631892600))
    
    @Binding var selectedDate: Date
    @Binding var selectedTimeZone: TimeZone
    
    @State private var selectedFormatStyle: DateFormat = dateFormats[0]
    
    @State private var selectedTimeZones: [TimeZone] = [
        TimeZone(identifier: "America/Los_Angeles")!,
        TimeZone(identifier: "America/New_York")!,
        TimeZone(identifier: "Europe/London")!,
        TimeZone(identifier: "Europe/Budapest")!,
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
            let abbr = fudgedAbbreviation(for: tz) ?? ""
            text += "\(flagForTimeZone(tz)) - \(selectedTimeInZone(tz)) \(abbr)\n"
        }
        return text
    }
    
    var body: some View {
        
        NavigationView {
            
            ScrollView(showsIndicators: true) {
                
                Group {
                    
                    DateTimeZonePicker(selectedDate: $selectedDate, selectedTimeZone: $selectedTimeZone, showDate: false)
                    
                }
                .padding(.horizontal, 8)
                
                List {
                    ForEach(selectedTimeZones, id: \.self) { tz in
                        HStack {
                            Text("\(flagForTimeZone(tz)) \(selectedTimeInZone(tz))")
                            Spacer()
                            if let abbreviation = fudgedAbbreviation(for: tz) {
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
                .scaledToFill()
                
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
                
            }
            .navigationTitle("Myke Mode")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
    }
    
    func move(from source: IndexSet, to destination: Int) {
        selectedTimeZones.move(fromOffsets: source, toOffset: destination)
    }
    
    func fudgedAbbreviation(for tz: TimeZone) -> String? {
        guard let abbreviation = tz.abbreviation(for: selectedDate) else { return nil }
        let isDaylightSavingTime = tz.isDaylightSavingTime(for: selectedDate)
        if tz.identifier == "Europe/London" && isDaylightSavingTime {
            return "BST"
        }
        if tz.identifier.starts(with: "Europe") {
            if isDaylightSavingTime && abbreviation == "GMT+2" || !isDaylightSavingTime && abbreviation == "GMT+1" {
                return "CET"
            }
        }
        return abbreviation
    }
    
}

struct MykeMode_Previews: PreviewProvider {
    static var previews: some View {
        MykeMode(selectedDate: .constant(Date()), selectedTimeZone: .constant(TimeZone(identifier: "America/Los_Angeles")!))
    }
}
