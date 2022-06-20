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
                
                HStack(alignment: .center) {
                    Image(systemName: dateFormat.icon)
                        .font(.title)
                        .foregroundColor(.secondary)
//                        .foregroundColor(.accentColor)
                    Spacer()
                    
                    Text(justCopied ? "Copied ✓" : "Copy")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color.accentColor)
                        .clipShape(
                            RoundedCorner(cornerRadius: 25)
                        )
                }
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
        .hoverEffect()
        .contextMenu {
            Text(dateFormat.name)
            Divider()
            Button(action: doCopy) {
                Label("Copy", systemImage: "doc.on.doc")
            }
            Button(action: doShare) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
    }
    
}

struct FormatChoiceButton_Previews: PreviewProvider {
    static var previews: some View {
        FormatChoiceButton(dateFormat: dateFormats[1], selectedDate: .constant(Date()), appendRelative: .constant(true), timeZone: .constant(TimeZone(identifier: "Australia/Brisbane")!))
    }
}
