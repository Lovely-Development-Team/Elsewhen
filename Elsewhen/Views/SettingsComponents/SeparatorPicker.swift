//
//  SeparatorPicker.swift
//  Elsewhen
//
//  Created by Ben Cardy on 29/12/2021.
//

import SwiftUI

struct SeparatorPicker: View {
    
    #if !os(macOS)
    @EnvironmentObject internal var orientationObserver: OrientationObserver
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var mykeModeSeparator: MykeModeSeparator
    
    var isPadAndNotSlideOver: Bool {
        DeviceType.isPad() && horizontalSizeClass != .compact
    }
    
    var content: some View {
        Form {
            ForEach(MykeModeSeparator.allCases, id: \.self) { sep in
                Button(action: {
                    mykeModeSeparator = sep
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        /// Without this delay, the binding doesn't properly update and the state doesn't change
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    HStack {
                        Text(sep.description)
                        Spacer()
                        if mykeModeSeparator == sep {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .navigationTitle("Separator")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    var body: some View {
        if isPadAndNotSlideOver {
            NavigationView {
                content
            }
            .navigationViewStyle(StackNavigationViewStyle())
        } else {
            content
        }
    }
}

struct SeparatorPicker_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SeparatorPicker(mykeModeSeparator: .constant(.noSeparator))
        }
        .environmentObject(OrientationObserver())
    }
}
