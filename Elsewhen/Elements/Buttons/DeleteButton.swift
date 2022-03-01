//
//  DeleteButton.swift
//  Elsewhen
//
//  Created by David Stephens on 23/09/2021.
//

import SwiftUI

struct DeleteButton: View {
    let text: String
    let onPress: () -> ()

    var body: some View {
        #if os(macOS)
        Button {
            onPress()
        } label: {
            Label(text, systemImage: "trash")
        }
        #else
        if #available(iOS 15.0, *) {
            Button(role: .destructive) {
                onPress()
            } label: {
                Label(text, systemImage: "trash")
            }
        } else {
            Button {
                onPress()
            } label: {
                Label(text, systemImage: "trash")
            }
        }
        #endif
    }
}

struct DeleteButton_Previews: PreviewProvider {
    static var previews: some View {
        DeleteButton(text: "Remove from List") { }
    }
}
