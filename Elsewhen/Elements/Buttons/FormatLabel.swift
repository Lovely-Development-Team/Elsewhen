//
//  FormatAsContextMenuLabel.swift
//  Elsewhen
//
//  Created by David on 20/10/2021.
//

import SwiftUI

struct FormatLabel: View {
    let style: DateFormat
    
    var body: some View {
        Label("Format as \(style.name)", systemImage: style.icon)
            .tag(style)
    }
}

struct FormatLabel_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(dateFormats, id: \.self) { formatStyle in
            FormatLabel(style: formatStyle)
        }
    }
}
