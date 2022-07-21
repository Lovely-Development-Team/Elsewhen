//
//  StarUnstarButton.swift
//  Elsewhen
//
//  Created by David Stephens on 22/09/2021.
//

import SwiftUI

struct StarUnstarButton: View {
    @Binding var isStarred: Bool
    
    var buttonView: some View {
        Button {
            isStarred.toggle()
        } label: {
            Label(isStarred ? "UNSTAR" : "STAR", systemImage: isStarred ? "star.slash" : "star.fill")
                .accessibilityHint(isStarred ? "STAR_HINT" : "UNSTAR_HINT")
        }
    }
    
    var body: some View {
        #if os(macOS)
        buttonView
        #else
        if #available(iOS 15.0, *) {
            buttonView
                .tint(isStarred ? nil : Color.yellow)
        } else {
            buttonView
        }
        #endif
    }
}

struct StarUnstarButton_Previews: PreviewProvider {
    static var previews: some View {
        StarUnstarButton(isStarred: .constant(true))
    }
}
