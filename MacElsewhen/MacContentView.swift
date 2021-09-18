//
//  ContentView.swift
//  ContentView
//
//  Created by David Stephens on 18/09/2021.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import os.log

struct MacContentView: View {
    var body: some View {
        ContentViewControllerRepresentable()
    }
}

struct MacContentView_Previews: PreviewProvider {
    static var previews: some View {
        MacContentView()
    }
}
