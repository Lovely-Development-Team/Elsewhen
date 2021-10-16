//
//  ShareButton.swift
//  Elsewhen
//
//  Created by Ben Cardy on 15/10/2021.
//

import SwiftUI

struct ShareButton: View {
    
    let generateText: () -> String
    
    @State private var showSharePopover: Bool = false
    
    var body: some View {
        Button(action: {
            if DeviceType.isPad() {
                showSharePopover = true
            } else {
                postShowShareSheet(with: [generateText()])
            }
        }) {
            Image(systemName: "square.and.arrow.up")
        }
        .popover(isPresented: $showSharePopover) {
            ActivityView(activityItems: [generateText()])
        }
    }
    
}

struct ShareButton_Previews: PreviewProvider {
    static var previews: some View {
        ShareButton(generateText: { "Foo" })
    }
}
