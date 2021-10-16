//
//  ShareButton.swift
//  Elsewhen
//
//  Created by Ben Cardy on 15/10/2021.
//

import SwiftUI

struct ShareButton: View {
    
    let generateText: () -> String
    
    @State private var showShareSheet: Bool = false
    @State private var showSharePopover: Bool = false
    
    var body: some View {
        Button(action: {
            if DeviceType.isPad() {
                showSharePopover = true
            } else {
                showShareSheet = true
            }
        }) {
            Image(systemName: "square.and.arrow.up")
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: [generateText()])
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
