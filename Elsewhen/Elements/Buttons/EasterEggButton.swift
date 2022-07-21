//
//  EasterEggButton.swift
//  Elsewhen
//
//  Created by David Stephens on 23/09/2021.
//

import SwiftUI

struct EasterEggButton: View {
    let onPress: () -> ()
    
    var body: some View {
        Button(action: {
            onPress()
        }, label: {
            HStack {
                Text("FROM_TLD")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Image("l2culogosvg")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.secondary)
                    .frame(height: 15)
                    .accessibility(hidden: true)
                
            }
        })
            .buttonStyle(PlainButtonStyle())
    }
}

struct EasterEggButton_Previews: PreviewProvider {
    static var previews: some View {
        EasterEggButton { }
    }
}
