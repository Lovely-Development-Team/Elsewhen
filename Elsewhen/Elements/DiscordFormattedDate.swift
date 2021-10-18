//
//  DiscordFormattedDate.swift
//  DiscordFormattedDate
//
//  Created by David on 06/09/2021.
//

import SwiftUI
import UniformTypeIdentifiers

struct DiscordFormattedDate: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(.body, design: .monospaced))
            .multilineTextAlignment(.center)
            .accessibility(hidden: true)
            .foregroundColor(.secondary)
            .onDrag {
                return NSItemProvider(item: text.data(using: .utf8)! as NSData, typeIdentifier: UTType.utf8PlainText.identifier)
            }
    }
}

struct DiscordFormattedDate_Previews: PreviewProvider {
    static var previews: some View {
        DiscordFormattedDate(text: String(describing: Date().timeIntervalSince1970))
    }
}
