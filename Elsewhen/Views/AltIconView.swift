//
//  AltIconView.swift
//  Elsewhen
//
//  Created by Ben Cardy on 04/11/2021.
//

import SwiftUI

struct AltIconView: View, OrientationObserving {
    
#if !os(macOS)
    @EnvironmentObject internal var orientationObserver: OrientationObserver
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
#endif
    
    @State private var containerWidth: CGFloat?
    
    @State var viewId = 1
    var done: () -> ()
    
    var columns: Int {
        Int(containerWidth ?? 300) / 90 - 1
    }
    
    var iconGrid: some View {
        let currentIconName = UIApplication.shared.alternateIconName
        return ScrollView {
            LazyVGrid(columns: Array(repeating: .init(alignment: .top), count: columns)) {
                ForEach(alternativeElsewhenIcons, id: \.name) { icon in
                    AltIconOption(icon: icon, selected: currentIconName == icon.fileName, onTap: setIcon)
                        .padding(.top, 20)
                }
            }
            .id(viewId)
            .padding([.bottom, .horizontal])
        }
        .navigationTitle(Text("App Icon"))
    }
    
    var body: some View {
        Group {
            if isPadAndNotCompact {
                NavigationView {
                    iconGrid
                        .navigationBarTitleDisplayMode(.inline)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            } else {
                iconGrid
            }
        }
        .background(GeometryReader { geometry in
            Color.clear.preference(
                key: AltIconPreferenceKey.self,
                value: geometry.size.width
            )
        })
        .onPreferenceChange(AltIconPreferenceKey.self) {
            containerWidth = $0
        }
    }
    
    private func setIcon(_ icon: AlternativeIcon) {
        UIApplication.shared.setAlternateIconName(icon.fileName)
        done()
        viewId += 1
    }
    
}

private extension AltIconView {
    struct AltIconPreferenceKey: PreferenceKey {
        static let defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat,
                           nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}

struct AltIconView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AltIconView() { }
        }.environmentObject(OrientationObserver())
    }
}
