//
//  AltIconView.swift
//  Elsewhen
//
//  Created by Ben Cardy on 04/11/2021.
//

import SwiftUI

struct Icon: View {
    
    let name: String
    let selected: Bool
    let onTap: (_ name: String?) -> ()
    var size: CGFloat = 80
    
    var body: some View {
        
        Button(action: {
            if !selected {
                onTap(name == "AppIcon" ? nil : name)
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
    
    @State var viewId = 1
    
    var body: some View {
        let currentIconName = UIApplication.shared.alternateIconName ?? "AppIcon"
        ScrollView {
            LazyVGrid(columns: [.init(), .init(), .init()]) {
                ForEach(icons, id: \.self) { iconName in
                    Icon(name: iconName, selected: currentIconName == "Icons/\(iconName)", onTap: setIcon)
                        .padding(.top, 20)
                }
            }
            .id(viewId)
        }
        .navigationTitle(Text("App Icon"))
    }
    
    private func setIcon(_ name: String?) {
        let iconPath: String?
        if let name = name {
            iconPath = "Icons/\(name)"
        } else {
            iconPath = nil
        }
        UIApplication.shared.setAlternateIconName(iconPath) { _ in
            viewId += 1
        }
    }
    
}

struct AltIconView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AltIconView()
        }
    }
}
