//
//  FormattedDateAndWarning.swift
//  Elsewhen
//
//  Created by David Stephens on 22/11/2021.
//

import SwiftUI

struct FormattedDateAndWarning: View {
    let display: String
    @Binding var showEasterEggSheet: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            
            DiscordFormattedDate(text: display)
                .padding(.bottom, 8)
            
            NotRepresentativeWarning()
                .padding(.bottom, 20)
            
            EasterEggButton {
                showEasterEggSheet = true
            }
            .padding(.vertical, 5)
            
        }
    }
}

struct FormattedDateAndWarning_Previews: PreviewProvider {
    static var previews: some View {
        FormattedDateAndWarning(display: discordFormat(for: Date(), in: .current, with: .D, appendRelative: true), showEasterEggSheet: .constant(false))
    }
}
