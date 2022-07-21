//
//  Changelog.swift
//  Elsewhen
//
//  Created by Ben Cardy on 03/07/2022.
//

import SwiftUI

struct Version {
    let number: String
    let bullets: [String]
}

let CHANGELOG: [Version] = [
    Version(
        number: "1.5",
        bullets: [
            "All-new interface for selecting dates, time code formats, and time zone lists.",
            "Time Zone Groups let you store combinations of Time Zones for quick access in the Time List tab. You can even share them with others, and import them from elsewhere into the app with the Import button in Settings."
        ]
    ),
    Version(number: "1.4", bullets: ["You can now choose a date in the Time list view, not just a time - handy for times in the future that fall between international clock changes."]),
    Version(number: "1.3", bullets: [
        "Smart Time Zone Search: the geographically closest time zone to your search term will help you find the right time zone quicker. For example, searching \"Cardiff, UK\" will bring up \"Europe/London\".",
        "A new option to choose whether the app opens at the Time Codes or Time list tab is available in Settings."
        ]
    ),
    Version(number: "1.2", bullets: ["Searching for time zones now accepts country names. For exmaple, try \"China\"."]),
    Version(number: "1.1", bullets: ["Now available: a choice of sixteen alternative app icons!"])
]

struct Changelog: View, OrientationObserving {
    
#if !os(macOS)
    @EnvironmentObject internal var orientationObserver: OrientationObserver
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
#endif
    
    @ViewBuilder
    var content: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(CHANGELOG, id: \.number) { version in
                    Group {
                        Text("Version \(version.number)")
                            .font(.system(size: 20, weight: .bold))
                            .padding(.bottom, 8)
                        ForEach(version.bullets, id: \.self) { bullet in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "circlebadge.fill")
                                    .font(.system(size: 10))
                                    .padding(.top, 6)
                                Text(bullet)
                            }
                        }
                    }
                    .multilineTextAlignment(.leading)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    Divider()
                        .padding(.vertical, 8)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
        }
        .navigationTitle(Text("VERSION_HISTORY_TITLE"))
    }
    
    var body: some View {
        if isPadAndNotCompact {
            NavigationView {
                content
                    .navigationBarTitleDisplayMode(.inline)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        } else {
            content
        }
    }
    
}

struct Changelog_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Changelog()
        }
    }
}
