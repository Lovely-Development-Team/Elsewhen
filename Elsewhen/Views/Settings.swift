//
//  Settings.swift
//  Elsewhen
//
//  Created by Ben Cardy on 06/11/2021.
//

import SwiftUI

struct Settings: View {
    var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink(destination: AltIconView()) {
                        Text("App Icon")
                    }
                }
                Section {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("\(AboutElsewhen.appVersion) (\(AboutElsewhen.buildNumber))")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(Text("Settings"))
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
