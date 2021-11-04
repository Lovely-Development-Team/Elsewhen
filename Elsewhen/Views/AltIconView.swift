//
//  AltIconView.swift
//  Elsewhen
//
//  Created by Ben Cardy on 04/11/2021.
//

import SwiftUI

struct Icon: View {
    
    let name: String
    var size: CGFloat = 80
    
    var selected: Bool {
        UIApplication.shared.alternateIconName ?? "AppIcon" == name
    }
    
    var body: some View {
        
        Button(action: {
            
            if selected {
                return
            }
            
            UIApplication.shared.setAlternateIconName(name) { done in
                print("Done: \(done)")
            }
            
        }) {
        
            VStack(spacing: 5) {
                
                Image(uiImage: UIImage(named: name) ?? UIImage())
                    .resizable()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: 10 / 57 * size, style: .continuous))
                
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                } else {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.secondary)
                        .opacity(0.5)
                }
                
            }
            
        }
        
    }
    
}

struct AltIconView: View {
    
    let icons = [
        "AppIcon",
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
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [.init(), .init(), .init()]) {
                ForEach(icons, id: \.self) { iconName in
                    Icon(name: iconName)
                        .padding(.top, 20)
//                        .padding(.bottom, )
                }
            }
        }
        .navigationTitle(Text("App Icon"))
    }
}

struct AltIconView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AltIconView()
        }
    }
}
