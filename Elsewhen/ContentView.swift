//
//  ContentView.swift
//  Elsewhen
//
//  Created by Ben Cardy on 04/09/2021.
//

import UIKit
import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers
import os.log

struct ContentView: View {
    
    @State private var selectedTab: Int = 0
    
    @State private var showEasterEggSheet: Bool = false
    @State private var showNewAppOverlay: Bool = true
    
    init() {
        // Disables the shadow pixel above the topbar
        UITabBar.appearance().clipsToBounds = true

        // Forces an opaque background on the tabbar, regardless of what is below it.
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().backgroundColor = UIColor.secondarySystemBackground
        UITabBar.appearance().backgroundImage = UIImage()
    }
    
    @ViewBuilder
    private var app: some View {
        TabView(selection: $selectedTab) {
            TimeCodeGeneratorView(showNewAppOverlay: $showNewAppOverlay)
                .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.secondary.opacity(0.5)), alignment: .bottom)
                .tabItem { Label("Time Codes", systemImage: "clock") }
                .tag(0)
            MykeMode(showNewAppOverlay: $showNewAppOverlay)
                .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.secondary.opacity(0.5)), alignment: .bottom)
                .tabItem { Label("Time List", systemImage: "list.dash") }
                .tag(1)
        }
    }
    
    var body: some View {
        if showNewAppOverlay {
            ZStack {

                app.blur(radius: 2)

                ScrollView {
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

                            Link(destination: URL(string: "https://apps.apple.com/app/id1588708173")!) {
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

                            Button(action: {
                                withAnimation {
                                    self.showNewAppOverlay = false
                                }
                            }) {
                                Text("Continue using this version for now")
                            }

                            Button(action: {
                                showEasterEggSheet = true
                            }, label: {
                                HStack {
                                    Text("From the Lovely Developers")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Image("l2culogosvg")
                                        .renderingMode(.template)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.secondary)
                                        .frame(height: 15)
                                        .accessibility(hidden: true)
                                        
                                }
                            })
                                .buttonStyle(PlainButtonStyle())
                                .padding(.vertical, 5)

                            Spacer()

                        }
                        .padding(.horizontal, 20)

                    }
                    .multilineTextAlignment(.center)
                }
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
        } else {
            app
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
