//
//  ContentView.swift
//  Elsewhen
//
//  Created by Ben Cardy on 04/09/2021.
//

import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers
import os.log

struct ContentView: View {
    
    @State private var selectedTab: Int = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TimeCodeGeneratorView()
                .tabItem { Label("Time Codes", systemImage: "clock") }
                .tag(0)
            MykeMode()
                .tabItem { Label("Myke Mode", systemImage: "keyboard") }
                .tag(1)
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
