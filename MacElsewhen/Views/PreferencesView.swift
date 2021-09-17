//
//  WidgetPreferencesView.swift
//  WidgetPreferencesView
//
//  Created by David Stephens on 17/09/2021.
//

import SwiftUI

struct PreferencesView: View {
    @AppStorage(UserDefaults.showMenuBarWidgetKey) private var showWidget: Bool = false
    @AppStorage(UserDefaults.shouldTerminateAfterLastWindowClosedKey) private var shouldTerminateAfterLastWindowClosed: Bool = false
    
    var body: some View {
        Toggle("Show widget in menu bar", isOn: $showWidget)
        Toggle("Terminate after last window is closed", isOn: $shouldTerminateAfterLastWindowClosed)
    }
}

struct WidgetPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
