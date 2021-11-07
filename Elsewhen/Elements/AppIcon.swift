//
//  AppIcon.swift
//  Elsewhen
//
//  Created by Ben Cardy on 07/11/2021.
//

import SwiftUI

struct AppIcon: View {
    
    let name: String?
    let size: CGFloat
    
    var body: some View {
        Image(uiImage: UIImage(named: name ?? "original") ?? UIImage())
            .resizable()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 10 / 57 * size, style: .continuous))
    }
}

struct AppIcon_Previews: PreviewProvider {
    static var previews: some View {
        AppIcon(name: "rainbow", size: 200)
    }
}
