//
//  MacDatePicker.swift
//  Elsewhen
//
//  Created by David Stephens on 28/09/2021.
//

import Foundation
import SwiftUI

struct MacDatePicker: NSViewRepresentable {
    typealias NSViewType = NSDatePicker
    @Binding var selectedDate: Date
    
    class Coordinator {
        @Binding var selectedDate: Date
        init(selectedDate: Binding<Date>) {
            self._selectedDate = selectedDate
        }
        
        @objc func updateDate(_ sender: NSDatePicker) {
            selectedDate = sender.dateValue
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(selectedDate: $selectedDate)
    }
    
    func makeNSView(context: Context) -> NSDatePicker {
        let datePicker = NSDatePicker()
        datePicker.dateValue = selectedDate
        datePicker.presentsCalendarOverlay = true
        datePicker.datePickerElements = [.yearMonthDay]
        datePicker.datePickerStyle = .clockAndCalendar
        datePicker.isBordered = false
        datePicker.target = context.coordinator
        datePicker.action = #selector(Coordinator.updateDate(_:))
        return datePicker
    }
    
    func updateNSView(_ nsView: NSDatePicker, context: Context) {
        
    }
    
}
