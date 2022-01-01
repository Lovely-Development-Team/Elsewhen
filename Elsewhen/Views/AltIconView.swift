//
//  AltIconView.swift
//  Elsewhen
//
//  Created by Ben Cardy on 04/11/2021.
//

import SwiftUI

struct AltIconView: View {
    
    #if !os(macOS)
    @EnvironmentObject internal var orientationObserver: OrientationObserver
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    
    @State var viewId = 1
    var done: () -> ()
    
    var isPadAndNotSlideOver: Bool {
        DeviceType.isPad() && horizontalSizeClass != .compact
    }
    
    var iconGrid: some View {
        let currentIconName = UIApplication.shared.alternateIconName
        return ScrollView {
            LazyVGrid(columns: Array(repeating: .init(alignment: .top), count: horizontalSizeClass == .compact || (DeviceType.isPad() && orientationObserver.currentOrientation == .portrait) ? 3 : 4)) {
                ForEach(alternativeElsewhenIcons, id: \.name) { icon in
                    AltIconOption(icon: icon, selected: currentIconName == icon.fileName, onTap: setIcon)
                        .padding(.top, 20)
                }
            }
            .id(viewId)
            .padding(.bottom)
        }
        .navigationTitle(Text("App Icon"))
    }
    
    var body: some View {
        Group {
            if isPadAndNotSlideOver {
                NavigationView {
                    iconGrid
                        .navigationBarTitleDisplayMode(.inline)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            } else {
                iconGrid
            }
        }
    }
    
    private func setIcon(_ icon: AlternativeIcon) {
        UIApplication.shared.setAlternateIconName(icon.fileName)
        done()
        viewId += 1
    }
    
}

struct AltIconView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AltIconView() { }
        }.environmentObject(OrientationObserver())
    }
}
