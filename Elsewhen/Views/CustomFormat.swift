//
//  CustomFormat.swift
//  Elsewhen
//
//  Created by Ben Cardy on 29/07/2022.
//

import SwiftUI

struct CustomFormat: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.colorSchemeContrast) var colorSchemeContrast
    
    @Binding var customFormat: String
    @Binding var selectedTimeZone: TimeZone?
    @ObservedObject var dateHolder: DateHolder

    @FocusState private var focusField: Bool
    @State private var size: CGSize = .zero
    
    let done: (() -> ())?
    
    var buttonTextColor: Color {
        if colorScheme == .dark && colorSchemeContrast == .increased {
            return .black
        }
        return .white
    }

    var formattedDate: AttributedString {
        var customFormatString = AttributedString(customFormat)
        for df in (dateFormats + [relativeDateFormat]) {
            var date = AttributedString(format(date: dateHolder.date, in: selectedTimeZone ?? TimeZone.current, with: df.code))
            date.foregroundColor = .accentColor
            while true {
                if let range = customFormatString.range(of: "[\(df.code.rawValue)]") {
                    customFormatString.replaceSubrange(range, with: date)
                } else {
                    break
                }
            }
        }
        return customFormatString
    }
    
    @ViewBuilder
    func buttonForFormat(_ df: DateFormat) -> some View {
        Button(action: {
            customFormat = customFormat + "[\(df.code.rawValue)]"
        }) {
            Text(format(date: dateHolder.date, in: selectedTimeZone ?? TimeZone.current, with: df.code))
                .multilineTextAlignment(.center)
                .foregroundColor(buttonTextColor)
        }
        .roundedRectangle()
        .onDrag {
            NSItemProvider(object: "[\(df.code.rawValue)]" as NSString)
        }
    }
    
    @ViewBuilder
    var viewBody: some View {
        VStack {
            Text("Enter a custom message, using the buttons below to add placeholders for the Time Codes.")
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            #if os(macOS)
                .frame(minHeight: 40)
            #endif
            GroupBox {
                TextField("Custom Format", text: $customFormat)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.leading)
                    .focused($focusField)
                if !customFormat.isEmpty {
                    Text(formattedDate)
                        .multilineTextAlignment(.leading)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.primary)
                }
            }
            .padding(.bottom)
            #if os(iOS)
            buttonForFormat(dateFormats[0])
            buttonForFormat(dateFormats[1])
            HStack {
                buttonForFormat(dateFormats[2])
                buttonForFormat(dateFormats[3])
            }
            HStack {
                buttonForFormat(dateFormats[4])
                buttonForFormat(dateFormats[5])
            }
            buttonForFormat(relativeDateFormat)
            .padding(.bottom)
            #else
            HStack {
                buttonForFormat(dateFormats[0])
                buttonForFormat(dateFormats[1])
            }
            HStack {
                buttonForFormat(dateFormats[2])
                buttonForFormat(dateFormats[3])
                buttonForFormat(dateFormats[4])
                buttonForFormat(dateFormats[5])
            }
            buttonForFormat(relativeDateFormat)
            .padding(.bottom)
            #endif
        }
    }
    
    var body: some View {
        Group {
            #if os(iOS)
            ScrollView {
                viewBody
                    .padding()
            }
            #else
            VStack {
                viewBody
                HStack {
                    Button(action: {
                        customFormat = ""
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                    }
                    .keyboardShortcut(.escape)
                    Button(action: {
                        if let done = done {
                            done()
                        }
                    }) {
                        Text("Save Custom Format")
                    }
                    .disabled(customFormat == "")
                }
            }
            .padding()
            .background {
                GeometryReader { geo in
                    Color.clear
                        .preference(key: SizePreferenceKey.self, value: geo.size)
                }
            }
            .onPreferenceChange(SizePreferenceKey.self) { size in
                self.size = size
            }
            #endif
        }
        .onAppear {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.focusField = true
          }
        }
        #if os(macOS)
        .frame(width: 500)
        .frame(height: size.height)
        #endif
    }
}

private struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

struct CustomFormat_Previews: PreviewProvider {
    static var previews: some View {
        CustomFormat(customFormat: .constant(""), selectedTimeZone: .constant(nil), dateHolder: DateHolder.shared, done: nil)
    }
}
