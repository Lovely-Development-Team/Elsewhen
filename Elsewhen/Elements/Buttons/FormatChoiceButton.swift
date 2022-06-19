//
//  FormatChoiceButton.swift
//  Elsewhen
//
//  Created by Ben Cardy on 18/06/2022.
//

import SwiftUI
import UniformTypeIdentifiers

struct FormatChoiceButton: View {
    
    let dateFormat: DateFormat
    @Binding var selectedDate: Date
    @Binding var appendRelative: Bool
    @Binding var timeZone: TimeZone?
    
    @State private var justCopied: Bool = false    
    @State private var notificationFeedbackGenerator: UINotificationFeedbackGenerator? = nil
    @State private var viewId: Int = 0
    
//    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    var resolvedTimeZone: TimeZone {
        timeZone ?? .current
    }
    
    var formattedDate: String {
        let date = format(date: selectedDate, in: resolvedTimeZone, with: dateFormat.code)
        if appendRelative && dateFormat != relativeDateFormat {
            let relative = format(date: selectedDate, in: resolvedTimeZone, with: relativeDateFormat.code)
            return "\(date) (\(relative))"
        }
        return date
    }
    
    var discordFormattedText: String {
        discordFormat(for: selectedDate, in: resolvedTimeZone, with: dateFormat.code, appendRelative: appendRelative)
    }
    
    func doCopy() {
        notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator?.prepare()
        EWPasteboard.set(discordFormattedText, forType: UTType.utf8PlainText)
        withAnimation {
            justCopied = true
        }
        notificationFeedbackGenerator?.notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                justCopied = false
            }
            notificationFeedbackGenerator = nil
        }
    }
    
    func doShare() {
        postShowShareSheet(with: [discordFormattedText])
    }
    
    var body: some View {
        Button(action: doCopy) {
            GroupBox {
                
                HStack {
                    Image(systemName: dateFormat.icon)
                    Text(dateFormat.name)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "doc.on.doc").opacity(0)
                    if justCopied {
                        Text("Copied ✓")
                    } else {
                        Image(systemName: "doc.on.doc")
                    }
                }
                .font(.caption)
                .foregroundColor(.accentColor)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 2)
                Text(formattedDate)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
                    .font(.system(.headline, design: .rounded))
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 2)
                
                Text(discordFormattedText)
                    .multilineTextAlignment(.leading)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                
            }
        }
        .contextMenu {
            Button(action: doCopy) {
                Label("Copy", systemImage: "doc.on.doc")
            }
            Button(action: doShare) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
//        .id(viewId)
//        .onReceive(timer) { input in
//            viewId += 1
//        }
    }
    
}

struct FormatChoiceButton_Previews: PreviewProvider {
    static var previews: some View {
        FormatChoiceButton(dateFormat: dateFormats[0], selectedDate: .constant(Date()), appendRelative: .constant(true), timeZone: .constant(TimeZone(identifier: "Australia/Brisbane")!))
    }
}
