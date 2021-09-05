//
//  ContentView.swift
//  Discord Helper
//
//  Created by Ben Cardy on 04/09/2021.
//

import SwiftUI
import MobileCoreServices

enum FormatCode: String {
    case f
    case F
    case D
    case t
    case T
    case R
}

struct DateFormat: Identifiable, Hashable {
    let icon: String
    let name: String
    let code: FormatCode
    
    var id: String { code.rawValue }
}

struct ContentView: View {
    
    @State private var selectedDate = Date()
    @State private var selectedFormatStyle: DateFormat = Self.dateFormats[0]
    @State private var showCopied: Bool = false
    
    static private let dateFormats: [DateFormat] = [
        DateFormat(icon: "calendar.badge.clock", name: "Full", code: .f),
        DateFormat(icon: "calendar.badge.plus", name: "Full with Day", code: .F),
        DateFormat(icon: "calendar", name: "Date only", code: .D),
        DateFormat(icon: "clock", name: "Time only", code: .t),
        DateFormat(icon: "clock.fill", name: "Time with seconds", code: .T),
        DateFormat(icon: "clock.arrow.2.circlepath", name: "Relative", code: .R),
    ]
    
    private var formattedDate: String {
        let dateFormatter = DateFormatter()
        switch selectedFormatStyle.code {
        case .f:
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
        case .F:
            dateFormatter.dateStyle = .full
            dateFormatter.timeStyle = .short
        case .D:
            dateFormatter.dateStyle = .long
        case .t:
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
        case .T:
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .medium
        case .R:
            let relativeFormatter = RelativeDateTimeFormatter()
            return relativeFormatter.localizedString(for: selectedDate, relativeTo: Date())
        }
        return dateFormatter.string(from: selectedDate)
    }
    
    private var discordFormat: String {
        "<t:\(Int(selectedDate.timeIntervalSince1970)):\(selectedFormatStyle.code.rawValue)>"
    }
    
    var body: some View {
        ZStack {
            VStack {
                DatePicker("Date", selection: $selectedDate)
                    .datePickerStyle(.graphical)
                    .padding(.horizontal, 30)
                HStack(spacing: 0) {
                    Spacer()
                    ForEach(Self.dateFormats, id: \.self) { formatStyle in
                        Button(action: {
                            self.selectedFormatStyle = formatStyle
                        }) {
                            Label(formatStyle.name, systemImage: formatStyle.icon)
                                .labelStyle(IconOnlyLabelStyle())
                                .foregroundColor(.white)
                                .font(.title)
                                .frame(width: 50, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(formatStyle == selectedFormatStyle ? Color.accentColor : .secondary)
                                )
                        }.buttonStyle(PlainButtonStyle())
                        Spacer()
                    }
                }
                Spacer()
                Text("\(formattedDate)*")
                    .font(.headline)
                Text(discordFormat)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
                Spacer()
                Button(action: {
                    UIPasteboard.general.setValue(self.discordFormat,
                                forPasteboardType: kUTTypePlainText as String)
                    withAnimation {
                        showCopied = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            showCopied = false
                        }
                    }
                }) {
                    Text("Copy Discord Code!")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(Color.accentColor)
                )
                Spacer()
                Text("*Representative of date and time components only; may not match exact Discord formatting.")
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        
            if showCopied {
                Text("Copied!")
                    .font(.title)
                    .fontWeight(.light)
                    .foregroundColor(.secondary)
                    .frame(width: 200, height: 200, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                    .opacity(0.95)
                    .transition(.opacity)
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
