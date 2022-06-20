//
//  DateTimeZoneSheet.swift
//  Elsewhen
//
//  Created by Ben Cardy on 18/06/2022.
//

import SwiftUI

struct DateTimeZoneSheet: View {
    
    // MARK: Init arguments
    
    @Binding var selectedDate: Date
    @Binding var selectedTimeZone: TimeZone?
    @Binding var selectedTimeZones: [TimeZone]
    @Binding var selectedTimeZoneGroup: TimeZoneGroup?
    let multipleTimeZones: Bool
    
    // MARK: State
    
    @State private var showTimeZoneChoiceSheet: Bool = false
    @State private var showTimeZoneGroupNameClashAlert: Bool = false
    @State private var pendingNewTimeZoneGroupName: String = ""
    
    var timeZoneLabel: String {
        multipleTimeZones ? "Time Zones" : "Time Zone"
    }
    
    var timeZoneButtonValue: String {
        multipleTimeZones ? "Choose Time Zones" : selectedTimeZone?.friendlyName ?? TimeZone.current.friendlyName
    }
    
    func showSaveGroupDialog(title: String, message: String, completion: @escaping (UIAlertAction, String) -> ()) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addTextField()
        let okAction = UIAlertAction(title: "Save", style: .default, handler: { action in
            completion(action, alertVC.textFields?.first?.text ?? "")
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        let viewController = UIApplication.shared.windows.first!.visibleViewController!
        viewController.present(alertVC, animated: true, completion: nil)
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Time").fontWeight(.semibold)
                Spacer()
                DatePicker("Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .labelsHidden()
                Button(action: {
                    withAnimation {
                        selectedDate = Date()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
                .hoverEffect()
            }
            HStack {
                Text(timeZoneLabel).fontWeight(.semibold)
                Spacer()
                Button(action: {
                    showTimeZoneChoiceSheet = true
                }) {
                    Text(timeZoneButtonValue)
                }
                .foregroundColor(.primary)
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .hoverEffect()
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(UIColor.systemGray5))
                )
            }
        }
        .padding([.horizontal, .bottom])
        .padding(.top, 10)
//        .background(
//            ZStack {
//                Rectangle().fill(Color(UIColor.systemBackground))
//                RoundedCorner(cornerRadius: 15, corners: [.topLeft, .topRight])
//                    .fill(Color(UIColor.secondarySystemBackground))
//                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 0)
//            }
//        )
        .sheet(isPresented: $showTimeZoneChoiceSheet) {
            NavigationView {
                TimezoneChoiceView(selectedTimeZone: $selectedTimeZone, selectedTimeZones: $selectedTimeZones, selectedDate: $selectedDate, selectMultiple: multipleTimeZones) {
                    showTimeZoneChoiceSheet = false
                }
                .navigationBarItems(leading: multipleTimeZones ? Button(action: {
                    showSaveGroupDialog(title: "Save as a Group?", message: "Provide a name for the Time Zone Group below.") { action, text in
                        if MykeModeTimeZoneGroupsController.shared.timeZoneGroups.map({ $0.name }).contains(text) {
                            pendingNewTimeZoneGroupName = text
                            showTimeZoneGroupNameClashAlert = true
                        } else {
                            let tzGroup = TimeZoneGroup(name: text, timeZones: selectedTimeZones)
                            MykeModeTimeZoneGroupsController.shared.addTimeZoneGroup(tzGroup)
                            selectedTimeZoneGroup = tzGroup
                            showTimeZoneChoiceSheet = false
                        }
                    }
                }) {
                    Text("Save...")
                } : nil, trailing: Button(action: {
                    if multipleTimeZones, let selectedTimeZoneGroup = selectedTimeZoneGroup, selectedTimeZones != selectedTimeZoneGroup.timeZones {
                        self.selectedTimeZoneGroup = nil
                    }
                    showTimeZoneChoiceSheet = false
                }) {
                    Text("Done")
                }
                )
                .alert(isPresented: $showTimeZoneGroupNameClashAlert) {
                    Alert(
                        title: Text("Group already exists"),
                        message: Text("Would you like to update the group \(pendingNewTimeZoneGroupName) with the selected Time Zones?"),
                        primaryButton: .default(Text("Update Group")) {
                            let tzGroup = MykeModeTimeZoneGroupsController.shared.retrieveTimeZoneGroup(byName: pendingNewTimeZoneGroupName)
                            MykeModeTimeZoneGroupsController.shared.updateTimeZoneGroup(tzGroup, with: selectedTimeZones)
                            selectedTimeZoneGroup = tzGroup
                            showTimeZoneChoiceSheet = false
                        },
                        secondaryButton: .cancel(Text("Cancel"))
                    )
                }
            }
        }
    }
    
}

struct DateTimeZoneSheet_Previews: PreviewProvider {
    static var previews: some View {
        DateTimeZoneSheet(selectedDate: .constant(Date()), selectedTimeZone: .constant(nil), selectedTimeZones: .constant([]), selectedTimeZoneGroup: .constant(nil), multipleTimeZones: false)
    }
}
