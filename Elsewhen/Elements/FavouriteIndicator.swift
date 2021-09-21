//
//  FavouriteIndicator.swift
//  FavouriteIndicator
//
//  Created by David on 21/09/2021.
//

import SwiftUI

struct FavouriteIndicator: View {
    @Binding var isFavourite: Bool
    
    var body: some View {
        if isFavourite {
            #if os(macOS)
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .onTapGesture {
                    isFavourite.toggle()
                }
            #else
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
            #endif
        } else if DeviceType.isMac() {
            Image(systemName: "star")
                .foregroundColor(.yellow)
                .onTapGesture {
                    isFavourite.toggle()
                }
        }
    }
}

struct FavouriteIndicator_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteIndicator(isFavourite: .constant(true))
    }
}
