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
    
    @State private var selectedDate = Date()
    @State private var selectedTimeZone: String = TimeZone.current.identifier
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TimeCodeGeneratorView(selectedDate: $selectedDate, selectedTimeZone: $selectedTimeZone)
                .tabItem { Label("Time Codes", systemImage: "clock") }
                .tag(0)
            MykeMode(selectedDate: $selectedDate, selectedTimeZone: $selectedTimeZone)
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
