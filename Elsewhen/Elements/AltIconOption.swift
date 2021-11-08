//
//  AltIconOption.swift
//  Elsewhen
//
//  Created by Ben Cardy on 07/11/2021.
//

import SwiftUI

struct AltIconOption: View {
    
    let icon: AlternativeIcon
    let selected: Bool
    let onTap: (_ icon: AlternativeIcon) -> ()
    var size: CGFloat = 80
    var borderWidth: CGFloat = 5
    
    var body: some View {
        Button(action: {
            if !selected {
                onTap(icon)
            }
        }) {
            VStack(spacing: 5) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10 / 57 * size, style: .continuous)
                        .fill(selected ? Color.accentColor : Color.secondary)
                        .frame(width: size + borderWidth, height: size + borderWidth)
                        .opacity(0.5)
                    AppIcon(icon: icon, size: size)
                }
                Text(icon.name)
                    .font(.caption)
                    .foregroundColor(selected ? .primary : .secondary)
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
        AltIconOption(icon: alternativeElsewhenIcons[0], selected: true, onTap: {icon in })
    }
}
