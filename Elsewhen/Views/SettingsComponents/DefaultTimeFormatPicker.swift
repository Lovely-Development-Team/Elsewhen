//
//  DefaultTimeFormatPicker.swift
//  Elsewhen
//
//  Created by Ben Cardy on 29/12/2021.
//

import SwiftUI

struct DefaultTimeFormatPicker: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var defaultTimeFormat: TimeFormat
    
    var content: some View {
        Form {
            ForEach(TimeFormat.allCases, id: \.self) { format in
                Button(action: {
                    defaultTimeFormat = format
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        /// Without this delay, the binding doesn't properly update and the state doesn't change
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    HStack {
                        Text(format.description)
                        Spacer()
                        if defaultTimeFormat == format {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .navigationTitle("Default Time Format")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var body: some View {
        if DeviceType.isPadAndNotCompact {
            NavigationView {
                content
            }
            .navigationViewStyle(StackNavigationViewStyle())
        } else {
            content
        }
    }
}

struct DefaultTimeFormatPicker_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DefaultTimeFormatPicker(defaultTimeFormat: .constant(.systemLocale))
        }
    }
}
