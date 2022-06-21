//
//  NewTimeZoneGroupView.swift
//  Elsewhen
//
//  Created by Ben Cardy on 21/06/2022.
//

import SwiftUI

struct NewTimeZoneGroupView: View {
    
    // MARK: Init
    @Binding var selectedTimeZones: [TimeZone]
    @Binding var selectedTimeZoneGroup: TimeZoneGroup?
    @Binding var sheetIsPresented: Bool
    
    // MARK: State
    @State private var name: String = ""
    @State private var nameClashes: Bool = false
    @FocusState private var nameInFocus: Bool
    
    var body: some View {
        Form {
            Section {
                Text("Enter a name to save the currently selected Time Zones as a group:")
                TextField("Group Name", text: $name)
                    .focused($nameInFocus)
            } footer: {
                VStack {
                    if nameClashes {
                        Text("A group with that name already exists. The contents will be updated with the currently selected Time Zones.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                            .font(.body)
                            .padding(.top)
                    }
                    HStack {
                        Button(action: {
                            var tzGroup: TimeZoneGroup? = nil
                            if nameClashes {
                                tzGroup = MykeModeTimeZoneGroupsController.shared.retrieveTimeZoneGroup(byName: name)
                                MykeModeTimeZoneGroupsController.shared.updateTimeZoneGroup(tzGroup!, with: selectedTimeZones)
                            } else {
                                tzGroup = TimeZoneGroup(name: name, timeZones: selectedTimeZones)
                                MykeModeTimeZoneGroupsController.shared.addTimeZoneGroup(tzGroup!)
                            }
                            selectedTimeZoneGroup = tzGroup
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
            NewTimeZoneGroupView(selectedTimeZones: .constant([]), selectedTimeZoneGroup: .constant(nil), sheetIsPresented: .constant(true))
                .navigationTitle("Save Time Zone Group")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
