//
//  NotRepresentativeWarning.swift
//  Elsewhen
//
//  Created by David on 19/10/2021.
//

import SwiftUI

struct NotRepresentativeWarning: View {
    var body: some View {
        Text("Date and time representative of components only; may not match exact Discord formatting.")
            .multilineTextAlignment(.center)
            .font(.caption2)
            .foregroundColor(.secondary)
            .padding(.horizontal)
    }
}

struct NotRepresentativeWarning_Previews: PreviewProvider {
    static var previews: some View {
        NotRepresentativeWarning()
    }
}
