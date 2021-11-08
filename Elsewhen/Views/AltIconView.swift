//
//  AltIconView.swift
//  Elsewhen
//
//  Created by Ben Cardy on 04/11/2021.
//

import SwiftUI

struct AltIconView: View {
    
    @State var viewId = 1
    
    var body: some View {
        let currentIconName = UIApplication.shared.alternateIconName
        ScrollView {
            LazyVGrid(columns: Array(repeating: .init(alignment: .top), count: 3)) {
                ForEach(alternativeElsewhenIcons, id: \.name) { icon in
                    AltIconOption(icon: icon, selected: currentIconName == icon.fileName, onTap: setIcon)
                        .padding(.top, 20)
                }
            }
            .id(viewId)
            .padding(.bottom)
        }
        .navigationTitle(Text("App Icon"))
    }
    
    private func setIcon(_ icon: AlternativeIcon) {
        UIApplication.shared.setAlternateIconName(icon.fileName)
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
