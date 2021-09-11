//
//  MykeMode.swift
//  MykeMode
//
//  Created by Ben Cardy on 11/09/2021.
//

import SwiftUI

struct MykeMode: View {
    
    @State private var selectedDate: Date = Date(timeIntervalSince1970: TimeInterval(1631892600))
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
                        if let abbreviation = tz.abbreviation() {
                            Text(abbreviation)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onMove(perform: move)
            }
            
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
