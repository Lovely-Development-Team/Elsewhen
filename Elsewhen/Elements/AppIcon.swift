//
//  AppIcon.swift
//  Elsewhen
//
//  Created by Ben Cardy on 07/11/2021.
//

import SwiftUI

struct AppIcon: View {
    
    let icon: AlternativeIcon
    let size: CGFloat
    
    var body: some View {
        Image(uiImage: icon.image)
            .resizable()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 10 / 57 * size, style: .continuous))
    }
}

struct AppIcon_Previews: PreviewProvider {
    static var previews: some View {
        AppIcon(icon: alternativeElsewhenIcons[0], size: 200)
    }
}
