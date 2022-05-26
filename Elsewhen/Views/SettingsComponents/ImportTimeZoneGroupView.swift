//
//  ImportTimeZoneGroupView.swift
//  Elsewhen
//
//  Created by Ben Cardy on 16/05/2022.
//

import SwiftUI

struct ImportTimeZoneGroupView: View {
    
    @EnvironmentObject private var timeZoneGroupController: MykeModeTimeZoneGroupsController
    
    @State private var clipboardContents: String? = nil
    @State private var timeZoneGroup: TimeZoneGroup? = nil
    @State private var nothingOnClipboard: Bool = false
    @State private var importIsDisabled: Bool = false
    
    @State private var editableGroupName: String = ""
    
    let done: () -> ()
    
    var body: some View {
        Group {
            if clipboardContents != nil {
                if let timeZoneGroup = timeZoneGroup, timeZoneGroup.timeZones.count > 0 {
                    ScrollView {
                        VStack {
                            Text(timeZoneGroup.name)
                                .font(.headline)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            ForEach(timeZoneGroup.timeZones, id: \.self) { tz in
                                HStack {
                                    Text(flagForTimeZone(tz))
                                    TimeZoneChoiceCell(tz: tz, isSelected: false, abbreviation: tz.fudgedAbbreviation(for: Date()), isFavourite: .constant(false), onSelect: {_ in }, isButton: false)
                                }
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding(.top)
                            }
                            
                            Button(action: doImport) {
                                Text(importIsDisabled ? "Update Time Zone Group" : "Import Time Zone Group")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .roundedRectangle()
                            .padding()
                            if importIsDisabled {
                                Text("You already have a Time Zone Group with this name. Importing this Group will update the existing one.")
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .multilineTextAlignment(.center)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                    }
                } else {
                    VStack {
                        Spacer()
                        Image(systemName: "clock.badge.exclamationmark")
                            .font(.system(size: 120))
                            .foregroundColor(.secondary)
                            .opacity(0.75)
                            .padding(.bottom)
                        Text("Couldn't parse the clipboard contents as a Time Zone Group.")
                            .multilineTextAlignment(.center)
                        Button(action: checkClipboard) {
                            Text("Try again")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .roundedRectangle()
                        .padding(.top)
                        Spacer()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                }
            } else {
                VStack {
                    Spacer()
                    if nothingOnClipboard {
                        Image(systemName: "square.dashed")
                            .font(.system(size: 120))
                            .foregroundColor(.secondary)
                            .opacity(0.75)
                            .padding(.bottom)
                        Text("Nothing found on the clipboard!")
                            .multilineTextAlignment(.center)
                        Button(action: checkClipboard) {
                            Text("Try again")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .roundedRectangle()
                        .padding(.top)
                        
                        
                    } else {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                    Spacer()
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
            }
        }
        .onAppear {
            checkClipboard()
        }
    }
    
    private func checkClipboard() {
        if let data = EWPasteboard.get() {
            nothingOnClipboard = false
            clipboardContents = data
            timeZoneGroup = timeZoneGroupController.parseTimeZoneGroupDetails(data)
            importIsDisabled = false
            if let timeZoneGroup = timeZoneGroup {
                editableGroupName = timeZoneGroup.name
                if timeZoneGroupController.timeZoneGroupNames.contains(timeZoneGroup.name) {
                    importIsDisabled = true
                }
            }
        } else {
            nothingOnClipboard = true
        }
    }
    
    private func doImport() {
        guard let timeZoneGroup = timeZoneGroup else {
            return
        }
        if importIsDisabled {
            timeZoneGroupController.updateTimeZoneGroup(timeZoneGroup, with: timeZoneGroup.timeZones)
        } else {
            timeZoneGroupController.addTimeZoneGroup(timeZoneGroup)
        }
        done()
    }
    
}

struct ImportTimeZoneGroupView_Previews: PreviewProvider {
    static var previews: some View {
        ImportTimeZoneGroupView() {
            
        }
    }
}
