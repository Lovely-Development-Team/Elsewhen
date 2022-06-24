//
//  ContentView.swift
//  Elsewhen
//
//  Created by Ben Cardy on 04/09/2021.
//

import UIKit
import SwiftUI
import UniformTypeIdentifiers
import os.log

struct ContentView: View {
    
    @State private var selectedTab: Int = 1
    @State private var showShareSheet: ShareSheetItem? = nil
    @AppStorage(UserDefaults.lastSeenVersionForSettingsKey) private var lastSeenVersionForSettings: String = ""
        
    init() {
        // Disables the shadow pixel above the topbar
        UITabBar.appearance().clipsToBounds = true
        
        // Forces an opaque background on the tabbar, regardless of what is below it.
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().backgroundColor = UIColor.secondarySystemBackground
        UITabBar.appearance().backgroundImage = UIImage()
    }
    
    var showSettingsIcon: Bool {
        return lastSeenVersionForSettings != AboutElsewhen.buildNumber
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            TimeCodeGeneratorView()
//            TimeCodeGeneratorView()
//                .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.secondary.opacity(0.5)), alignment: .bottom)
                .tabItem { Label("Time Codes", systemImage: "clock") }
                .tag(Tab.timeCodes.rawValue)
            MykeMode()
//                .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.secondary.opacity(0.5)), alignment: .bottom)
                .tabItem { Label("Time List", systemImage: "list.dash") }
                .tag(Tab.mykeMode.rawValue)
            
            Settings(selectedTab: $selectedTab)
                .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.secondary.opacity(0.5)), alignment: .bottom)
                .tabItem { Label("Settings", systemImage: "gear") }
                .iconBadge(isPresented: showSettingsIcon)
                .tag(Tab.settings.rawValue)
            
        }
        .sheet(item: $showShareSheet) { item in
            ActivityView(activityItems: item.items)
        }
        .onReceive(NotificationCenter.default.publisher(for: .EWShouldOpenShareSheet, object: appDelegate())) { notification in
            guard let activityItems = notification.userInfo?[ActivityItemsKey] as? [Any] else {
                return
            }
            showShareSheet = .init(items: activityItems)
        }
        .onAppear {
            selectedTab = UserDefaults.standard.defaultTab
        }
        .onChange(of: selectedTab) { [selectedTab] newTab in
            if selectedTab == Tab.settings.rawValue {
                lastSeenVersionForSettings = AboutElsewhen.buildNumber
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            ContentView().environmentObject(OrientationObserver.shared)
        } else {
            ContentView()
        }
    }
}
