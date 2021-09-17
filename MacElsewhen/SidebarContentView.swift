//
//  ContentView.swift
//  ContentView
//
//  Created by David Stephens on 17/09/2021.
//

import Foundation

import SwiftUI
import UniformTypeIdentifiers
import os.log

enum SidebarSelection {
    case generator
    case mykeMode
}

struct SidebarContentView: View {
    
    @State private var selectedTab: SidebarSelection? = .generator
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(tag: SidebarSelection.generator, selection: $selectedTab) {
                    TimeCodeGeneratorView()
                        .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.secondary.opacity(0.5)), alignment: .bottom)
                } label: {
                    Label("Time Codes", systemImage: "clock")
                }
                NavigationLink(tag: SidebarSelection.mykeMode, selection: $selectedTab) {
                    MykeMode()
                        .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.secondary.opacity(0.5)), alignment: .bottom)
                } label: {
                    Label("Time List", systemImage: "list.dash")
                }
            }
            .listStyle(SidebarListStyle())
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleSidebar, label: {
                        Image(systemName: "sidebar.leading")
                    })
                }
            }
        }
    }
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
    
}

struct SidebarContentView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarContentView()
    }
}
