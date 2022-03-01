//
//  TextFieldAlert.swift
//  Elsewhen
//
//  Created by Ben Cardy on 19/02/2022.
//

import SwiftUI
import Foundation


struct TextFieldAlert: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UIAlertController
    
    func makeUIViewController(context: Context) -> UIAlertController {
        return UIAlertController(title: "Enter something?", message: "Do something", preferredStyle: .alert)
    }
    
    func updateUIViewController(_ uiViewController: UIAlertController, context: Context) {
        uiViewController.addTextField()
    }
    
}
