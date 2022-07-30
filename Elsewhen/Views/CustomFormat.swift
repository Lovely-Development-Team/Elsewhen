//
//  CustomFormat.swift
//  Elsewhen
//
//  Created by Ben Cardy on 29/07/2022.
//

import SwiftUI

struct CustomFormat: View {
    
    @Binding var customFormat: String
    
    var body: some View {
        ScrollView {
            VStack {
                TextField("Custom Format", text: $customFormat)
                    .textFieldStyle(.roundedBorder)
                ForEach(dateFormats, id: \.self) { df in
                    Button(action: {
                        customFormat = customFormat + "[\(df.code.rawValue)]"
                    }) {
                        HStack {
                            Image(systemName: df.icon)
                            Text(df.name)
                        }
                        .foregroundColor(.white)
                    }
                    .roundedRectangle()
                }
            }
            .padding()
        }
    }
}

struct CustomFormat_Previews: PreviewProvider {
    static var previews: some View {
        CustomFormat(customFormat: .constant(""))
    }
}
