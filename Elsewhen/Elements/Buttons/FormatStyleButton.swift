//
//  FormatStyleButton.swift
//  Elsewhen
//
//  Created by David on 19/10/2021.
//

import SwiftUI

struct FormatStyleButton: View {
    // MARK: Environment
    @Environment(\.isInPopover) private var isInPopover
    
    // MARK: Parameters
    let formatStyle: DateFormat
    let isSelected: Bool
    let onTap: (DateFormat) -> ()
    
    #if !os(macOS)
    private static let buttonFrame: CGFloat = 50
    #else
    private static let buttonFrame: CGFloat = 40
    #endif
        
    #if !os(macOS)
    private static let formatButtonStyle = DefaultButtonStyle()
    #else
    private static let formatButtonStyle = PlainButtonStyle()
    #endif
    
    @ViewBuilder
    private func formatStyleButton(for formatStyle: DateFormat) -> some View {
        Label(formatStyle.name, systemImage: formatStyle.icon)
            .labelStyle(IconOnlyLabelStyle())
            .foregroundColor(.white)
            .font(.title)
            .frame(width: Self.buttonFrame, height: Self.buttonFrame)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? Color.accentColor : .secondary)
            )
    }
    
    var body: some View {
        Button(action: {
            onTap(formatStyle)
        }) {
            HStack {
                formatStyleButton(for: formatStyle)
                    .help(Text(formatStyle.name))
                if !isInPopover {
                    Text(formatStyle.name)
                        .foregroundColor(isSelected ? Color.accentColor : .secondary)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: isInPopover ? .center : .leading)
        }
        .buttonStyle(Self.formatButtonStyle)
    }
}

struct FormatStyleButton_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(dateFormats, id: \.self) { formatStyle in
            FormatStyleButton(formatStyle: formatStyle, isSelected: false, onTap: {_ in })
        }
    }
}
