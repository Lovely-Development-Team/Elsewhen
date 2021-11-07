//
//  AltIconOption.swift
//  Elsewhen
//
//  Created by Ben Cardy on 07/11/2021.
//

import SwiftUI

struct AltIconOption: View {
    
    let name: String
    let selected: Bool
    let onTap: (_ name: String?) -> ()
    var size: CGFloat = 80
    
    var body: some View {
        
        Button(action: {
            if !selected {
                onTap(name == "original" ? nil : name)
            }
        }) {
        
            VStack(spacing: 5) {
                
                AppIcon(name: name, size: size)
                
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

struct AltIconOption_Previews: PreviewProvider {
    static var previews: some View {
        AltIconOption(name: "rainbow", selected: true, onTap: {name in })
    }
}
