//
//  ContentView.swift
//  Elsewhen
//
//  Created by Ben Cardy on 04/09/2021.
//

#if canImport(UIKit)
import UIKit
#endif
import SwiftUI
import UniformTypeIdentifiers
import os.log

struct ContentView: View {
    
    @State private var selectedTab: Int = 0
    @State private var showShareSheet: ShareSheetItem? = nil
    
    init() {
#if canImport(UIKit)
        // Disables the shadow pixel above the topbar
        UITabBar.appearance().clipsToBounds = true
        
        // Forces an opaque background on the tabbar, regardless of what is below it.
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().backgroundColor = UIColor.secondarySystemBackground
        UITabBar.appearance().backgroundImage = UIImage()
#endif
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            TimeCodeGeneratorView()
#if !os(macOS)
                .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.secondary.opacity(0.5)), alignment: .bottom)
#endif
                .tabItem { Label("Time Codes", systemImage: "clock") }
                .tag(0)
            MykeMode()
#if !os(macOS)
                .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.secondary.opacity(0.5)), alignment: .bottom)
#endif
                .tabItem { Label("Time List", systemImage: "list.dash") }
                .tag(1)
#if !os(macOS)
            
            NavigationView {
                AltIconView()
            }
                .navigationViewStyle(StackNavigationViewStyle())
                .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.secondary.opacity(0.5)), alignment: .bottom)
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(2)
#endif
            
        }
        .sheet(item: $showShareSheet) { item in
#if !os(macOS)
            ActivityView(activityItems: item.items)
#endif
        }
        .onReceive(NotificationCenter.default.publisher(for: .EWShouldOpenShareSheet, object: appDelegate())) { notification in
            guard let activityItems = notification.userInfo?[ActivityItemsKey] as? [Any] else {
                return
            }
            showShareSheet = .init(items: activityItems)
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
#if !os(macOS)
        if #available(iOS 15.0, *) {
            ContentView().previewInterfaceOrientation(.landscapeRight).environmentObject(OrientationObserver.shared)
        } else {
            ContentView()
        }
#else
        ContentView()
#endif
    }
}
