//
//  NewTimeZoneGroupView.swift
//  Elsewhen
//
//  Created by Ben Cardy on 21/06/2022.
//

import SwiftUI

struct NewTimeZoneGroupView: View {
    
    // MARK: State
    @Binding var selectedTimeZones: [TimeZone]
    @Binding var sheetIsPresented: Bool
    @State private var name: String = ""
    @State private var nameClashes: Bool = false
    @FocusState private var nameInFocus: Bool
    
    var body: some View {
        Form {
            Section {
                TextField("Group Name", text: $name)
                    .focused($nameInFocus)
            } footer: {
                VStack {
                    if nameClashes {
                        Text("A group with that name already exists.")
                            .foregroundColor(.primary)
                            .font(.body)
                            .padding(.top)
                    }
                    HStack {
                        Button(action: {
                            if nameClashes {
                                let tzGroup = MykeModeTimeZoneGroupsController.shared.retrieveTimeZoneGroup(byName: name)
                                MykeModeTimeZoneGroupsController.shared.updateTimeZoneGroup(tzGroup, with: selectedTimeZones)
                            } else {
                                let tzGroup = TimeZoneGroup(name: name, timeZones: selectedTimeZones)
                                MykeModeTimeZoneGroupsController.shared.addTimeZoneGroup(tzGroup)
                            }
                            sheetIsPresented = false
                        }) {
                            Text(nameClashes ? "Update Time Zone Group" : "Save Time Zone Group")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(10)
                        }
                        .roundedRectangle()
                        .padding()
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            }
        }
        .onAppear {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.nameInFocus = true
          }
        }
        .onChange(of: name) { newName in
            nameClashes = MykeModeTimeZoneGroupsController.shared.timeZoneGroups.map({ $0.name }).contains(newName)
        }
    }
}

struct NewTimeZoneGroupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewTimeZoneGroupView(selectedTimeZones: .constant([]), sheetIsPresented: .constant(true))
                .navigationTitle("Save Time Zone Group")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
