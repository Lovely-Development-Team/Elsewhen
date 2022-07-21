//
//  DefaultTabPicker.swift
//  Elsewhen
//
//  Created by Ben Cardy on 18/01/2022.
//

import SwiftUI





struct DefaultTabPicker: View, OrientationObserving {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject internal var orientationObserver: OrientationObserver
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @Binding var defaultTabIndex: Int
    
    private func setDefaultTab(_ defaultTab: Int) {
        defaultTabIndex = defaultTab
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            /// Without this delay, the binding doesn't properly update and the state doesn't change
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    var content: some View {
        Form {
            Button(action: {
                setDefaultTab(Tab.timeCodes.rawValue)
            }) {
                HStack {
                    Text("TIME_CODES_LABEL")
                    Spacer()
                    if defaultTabIndex == Tab.timeCodes.rawValue {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            Button(action: {
                setDefaultTab(Tab.mykeMode.rawValue)
            }) {
                HStack {
                    Text("TIME_LIST_LABEL")
                    Spacer()
                    if defaultTabIndex == Tab.mykeMode.rawValue {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .foregroundColor(.primary)
        .navigationTitle("DEFAULT_TAB_TITLE")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    var body: some View {
        if isPadAndNotCompact {
            NavigationView {
                content
            }
            .navigationViewStyle(StackNavigationViewStyle())
        } else {
            content
        }
    }
    
}

struct DefaultTabPicker_Previews: PreviewProvider {
    static var previews: some View {
        DefaultTabPicker(defaultTabIndex: .constant(1))
    }
}
