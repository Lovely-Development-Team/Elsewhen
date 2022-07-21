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
#if os(iOS)
    @State private var notificationFeedbackGenerator: UINotificationFeedbackGenerator? = nil
#endif
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
#if os(iOS)
        notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator?.prepare()
#endif
        EWPasteboard.set(discordFormattedText, forType: UTType.utf8PlainText)
        withAnimation {
            justCopied = true
        }
#if os(iOS)
        notificationFeedbackGenerator?.notificationOccurred(.success)
#endif
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                justCopied = false
            }
#if os(iOS)
            notificationFeedbackGenerator = nil
#endif
        }
    }
    
    func doShare() {
        postShowShareSheet(with: [discordFormattedText])
    }
    
    @ViewBuilder
    var timeFormatView: some View {
        GroupBox {
            
            HStack(alignment: .center) {
                Image(systemName: dateFormat.icon)
                    .font(.title)
                    .foregroundColor(.secondary)
                Spacer()
                
#if os(iOS)
                Text(justCopied ? "COPIED_IOS_BUTTON" : "COPY")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(Color.accentColor)
                    .clipShape(
                        RoundedCorner(cornerRadius: 25)
                    )
#else
                Text("COPIED_MACOS_BUTTON").opacity(justCopied ? 1 : 0)
                Button(action: doCopy) {
                    Text("COPY")
                }
#endif
            }
            .padding(.bottom, 2)
            
            Text(formattedDate)
                .multilineTextAlignment(.leading)
#if os(macOS)
                .textSelection(.enabled)
                .foregroundColor(.accentColor)
                .font(.system(.body, design: .rounded))
            #else
                .foregroundColor(.primary)
                .font(.system(.headline, design: .rounded))
#endif
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 2)
            
            Text(discordFormattedText)
                .textSelection(.enabled)
                .multilineTextAlignment(.leading)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
        }
        .contextMenu {
            Text(dateFormat.name)
            Divider()
            Button(action: doCopy) {
                Label("COPY", systemImage: "doc.on.doc")
            }
            Button(action: doShare) {
                Label("SHARE", systemImage: "square.and.arrow.up")
            }
        }
    }
    
    var body: some View {
#if os(iOS)
        Button(action: doCopy) {
            timeFormatView
        }
        .hoverEffect()
#else
        timeFormatView
#endif
    }
    
}

struct FormatChoiceButton_Previews: PreviewProvider {
    static var previews: some View {
        FormatChoiceButton(dateFormat: dateFormats[1], selectedDate: .constant(Date()), appendRelative: .constant(true), timeZone: .constant(TimeZone(identifier: "Australia/Brisbane")!))
    }
}
