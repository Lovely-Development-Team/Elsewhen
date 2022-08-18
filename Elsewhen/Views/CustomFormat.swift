//
//  CustomFormat.swift
//  Elsewhen
//
//  Created by Ben Cardy on 29/07/2022.
//

import SwiftUI

struct CustomFormat: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.colorSchemeContrast) var colorSchemeContrast
    
    @Binding var customFormat: String
    @Binding var selectedTimeZone: TimeZone?
    @ObservedObject var dateHolder: DateHolder

    @FocusState private var focusField: Bool
    
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
                .foregroundColor(buttonTextColor)
        }
        .roundedRectangle()
        .onDrag {
            NSItemProvider(object: "[\(df.code.rawValue)]" as NSString)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
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
            }
            .padding()
        }
        .onAppear {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.focusField = true
          }
        }
    }
}

struct CustomFormat_Previews: PreviewProvider {
    static var previews: some View {
        CustomFormat(customFormat: .constant(""), selectedTimeZone: .constant(nil), dateHolder: DateHolder.shared)
    }
}
