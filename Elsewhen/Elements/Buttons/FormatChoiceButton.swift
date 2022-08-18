//
//  FormatChoiceButton.swift
//  Elsewhen
//
//  Created by Ben Cardy on 18/06/2022.
//

import SwiftUI
import UniformTypeIdentifiers

struct FormatChoiceButton: View {
    
    @EnvironmentObject private var customTimeFormatController: NSUbiquitousKeyValueStoreController
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.colorSchemeContrast) var colorSchemeContrast
    
    let dateFormat: DateFormat?
    let customFormat: CustomTimeFormat?
    @Binding var selectedDate: Date
    @Binding var appendRelative: Bool
    @Binding var timeZone: TimeZone?
    
    @ObservedObject var dateHolder: DateHolder
    
    @State private var editCustomFormatString: String = ""
    @State private var editingCustomFormat: Bool = false
    
    @State private var justCopied: Bool = false
#if os(iOS)
    @State private var notificationFeedbackGenerator: UINotificationFeedbackGenerator? = nil
#endif
    @State private var viewId: Int = 0
    
    var resolvedTimeZone: TimeZone {
        timeZone ?? .current
    }
    
    var buttonTextColor: Color {
        if colorScheme == .dark && colorSchemeContrast == .increased {
            return .black
        }
        return .white
    }
    
    var formattedDate: String {
        if let dateFormat = dateFormat {
            let date = format(date: selectedDate, in: resolvedTimeZone, with: dateFormat.code)
            if appendRelative && dateFormat != relativeDateFormat {
                let relative = format(date: selectedDate, in: resolvedTimeZone, with: relativeDateFormat.code)
                return "\(date) (\(relative))"
            }
            return date
        } else {
            var customFormat = customFormat?.format ?? ""
            for df in (dateFormats + [relativeDateFormat]) {
                let date = format(date: selectedDate, in: resolvedTimeZone, with: df.code)
                customFormat = customFormat.replacingOccurrences(of: "[\(df.code.rawValue)]", with: date)
            }
            return customFormat
        }
    }
    
    var discordFormattedText: String {
        if let dateFormat = dateFormat {
            return discordFormat(for: selectedDate, in: resolvedTimeZone, with: dateFormat.code, appendRelative: appendRelative)
        } else {
            var customFormat = customFormat?.format ?? ""
            for df in (dateFormats + [relativeDateFormat]) {
                let discordFormat = discordFormat(for: selectedDate, in: resolvedTimeZone, with: df.code, appendRelative: false)
                customFormat = customFormat.replacingOccurrences(of: "[\(df.code.rawValue)]", with: discordFormat)
            }
            return customFormat
        }
    }
    
    var color: Color {
        if let customFormat = customFormat {
            return customFormat.color
        }
        return Color.accentColor
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
                Image(systemName: dateFormat?.icon ?? customFormat?.icon ?? "star")
                    .font(.title)
                    .foregroundColor(.secondary)
                Spacer()
                
#if os(iOS)
                Text(justCopied ? "Copied ✓" : "Copy")
                    .font(.headline)
                    .foregroundColor(buttonTextColor)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(Color.accentColor)
                    .clipShape(
                        RoundedCorner(cornerRadius: 25)
                    )
#else
                Text("Copied!").opacity(justCopied ? 1 : 0)
                Button(action: doCopy) {
                    Text("Copy")
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
            Text(dateFormat?.name ?? "Custom Format")
            Divider()
            Button(action: doCopy) {
                Label("Copy", systemImage: "doc.on.doc")
            }
            Button(action: doShare) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            if let customFormat = customFormat {
                Button(action: {
                    editCustomFormatString = customFormat.format
                    editingCustomFormat = true
                }) {
                    Label("Edit Custom Format", systemImage: "pencil")
                }
                Button(action: {
                    postShowShareSheet(with: [customFormat.format])
                }) {
                    Label("Share Custom Format", systemImage: "square.and.arrow.up")
                }
                DeleteButton(text: "Remove Custom Format") {
                    customTimeFormatController.removeCustomTimeFormat(customFormat)
                }
            }
        }
        .sheet(isPresented: $editingCustomFormat) {
            NavigationView {
                CustomFormat(customFormat: $editCustomFormatString, selectedTimeZone: $timeZone, dateHolder: dateHolder)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Save") {
                                guard let customFormat = customFormat else { return }
                                customTimeFormatController.updateCustomTimeFormat(id: customFormat.id, formatString: editCustomFormatString)
                                editingCustomFormat = false
                            }
                            .disabled(editCustomFormatString == "")
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                editingCustomFormat = false
                            }
                        }
                    }
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
        VStack {
            FormatChoiceButton(dateFormat: dateFormats[1], customFormat: nil, selectedDate: .constant(Date()), appendRelative: .constant(true), timeZone: .constant(TimeZone(identifier: "Australia/Brisbane")!), dateHolder: DateHolder.shared)
            FormatChoiceButton(dateFormat: nil, customFormat: CustomTimeFormat(id: UUID(), format: "[d] at [t] [R]", icon: "dollarsign", red: 0.5, green: 0.2, blue: 0.5), selectedDate: .constant(Date()), appendRelative: .constant(true), timeZone: .constant(TimeZone(identifier: "Australia/Brisbane")!), dateHolder: DateHolder.shared)
        }
        .padding()
    }
}
