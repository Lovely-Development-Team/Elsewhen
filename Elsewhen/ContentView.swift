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
    @State private var showEasterEggSheet: Bool = false
    
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
        
        ZStack {
        
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
                
            }
            .blur(radius: 2)
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
            
            VStack(spacing: 40) {
                
                Group {
                                
                    HStack {
                        Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                            .resizable()
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)
                        Text("Elsewhen")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.black.opacity(0.8))
                    }
                    .padding(.top, 40)
                    
                    Text("Elsewhen is now available on the App Store!")
                    
                    Link(destination: URL(string: "https://www.apple.com")!) {
                        Image("AppStoreBadge")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200)
                    }
                    
                    Text("This TestFlight has also been replaced, and will no longer be updated. Tap below to access the new TestFlight and continue receiving beta updates!")
                    
                    Link(destination: URL(string: "https://testflight.apple.com/join/pWKcjt7i")!) {
                        Text("Download on TestFlight")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .background(
                        Rectangle()
                            .fill(Color(red: 49/255, green: 121/255, blue: 255/255))
                    )
                    .cornerRadius(14)
                    
                    Text("Thank you for using Elsewhen and helping us improve the app.")
                        .foregroundColor(.secondary)
                    
                    EasterEggButton {
                        self.showEasterEggSheet = true
                    }
                    
                    Spacer()
                    
                }
                .padding(.horizontal, 20)
                
            }
            .multilineTextAlignment(.center)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(
                Rectangle()
                    .fill(.white)
                    .cornerRadius(25)
                    .opacity(0.9)
            )
            .edgesIgnoringSafeArea(.bottom)
            
        }
        .sheet(isPresented: $showEasterEggSheet) {
            EasterEggView()
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
