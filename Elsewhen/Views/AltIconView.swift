//
//  AltIconView.swift
//  Elsewhen
//
//  Created by Ben Cardy on 04/11/2021.
//

import SwiftUI

struct AltIconView: View {
    
    let icons = [
        "original",
        "rainbow",
        "agender",
        "nonbinary",
        "asexual",
        "lesbian",
        "pansexual",
        "genderqueer",
        "genderfluid",
        "bisexual",
        "aromantic"
    ]
    
    @State var viewId = 1
    
    var body: some View {
        let currentIconName = UIApplication.shared.alternateIconName ?? "original"
        ScrollView {
            LazyVGrid(columns: [.init(), .init(), .init()]) {
                ForEach(icons, id: \.self) { iconName in
                    AltIconOption(name: iconName, selected: currentIconName == iconName, onTap: setIcon)
                        .padding(.top, 20)
                }
            }
            .id(viewId)
        }
        .navigationTitle(Text("App Icon"))
    }
    
    private func setIcon(_ name: String?) {
        UIApplication.shared.setAlternateIconName(name)
        viewId += 1
    }
    
}

struct AltIconView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AltIconView()
        }
    }
}
