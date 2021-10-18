//
//  DeleteButton.swift
//  Elsewhen
//
//  Created by David Stephens on 23/09/2021.
//

import SwiftUI

struct DeleteButton: View {
    let onPress: () -> ()

    var body: some View {
        #if os(macOS)
        Button {
            onPress()
        } label: {
            Label("Remove from List", systemImage: "trash")
        }
        #else
        if #available(iOS 15.0, *) {
            Button(role: .destructive) {
                onPress()
            } label: {
                Label("Remove from List", systemImage: "trash")
            }
        } else {
            Button {
                onPress()
            } label: {
                Label("Remove from List", systemImage: "trash")
            }
        }
        #endif
    }
}

struct DeleteButton_Previews: PreviewProvider {
    static var previews: some View {
        DeleteButton { }
    }
}
