//
//  MykeMode.swift
//  MykeMode
//
//  Created by Ben Cardy on 11/09/2021.
//

import SwiftUI
import UniformTypeIdentifiers

struct MykeMode: View {
    
    @State private var selectedDate: Date = Date(timeIntervalSince1970: TimeInterval(1639239835))
//    @State private var selectedDate: Date = Date(timeIntervalSince1970: TimeInterval(1631892600))
    @State private var selectedTimeZones: [TimeZone] = [
        TimeZone(identifier: "America/Los_Angeles")!,
        TimeZone(identifier: "America/New_York")!,
        TimeZone(identifier: "Europe/London")!,
        TimeZone(identifier: "Europe/Budapest")!,
    ]
    
    func selectedTimeInZone(_ zone: TimeZone) -> String {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .short
        df.timeZone = zone
        df.locale = Locale(identifier: "en/us")
        return df.string(from: selectedDate)
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            
            Text("\(selectedDate)")
            
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
                .onDrop(of: [UTType.json], delegate: TimeZone.TZDropDelegate(onDrop: { timezone in
                    guard let timezone = timezone else {
                        return
                    }
                    selectedTimeZones.append(timezone)
                }))
            }
            
        }
        
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
        MykeMode()
    }
}
