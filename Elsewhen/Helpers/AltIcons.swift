//
//  AltIcons.swift
//  Elsewhen
//
//  Created by Ben Cardy on 07/11/2021.
//

import UIKit
import Foundation

struct AlternativeIcon {
    let fileName: String?
    let name: String
    
    var image: UIImage {
        UIImage(named: fileName ?? "original") ?? UIImage()
    }
    
}

let alternativeElsewhenIcons: [AlternativeIcon] = [
    AlternativeIcon(fileName: nil, name: "Original"),
    AlternativeIcon(fileName: "wiggles", name: "Wiggles"),
    AlternativeIcon(fileName: "sixcolors", name: "Six Colours"),
    AlternativeIcon(fileName: "rainbow", name: "Pride Flag"),
    AlternativeIcon(fileName: "agender", name: "Agender Flag"),
    AlternativeIcon(fileName: "asexual", name: "Asexual Flag"),
    AlternativeIcon(fileName: "aromantic", name: "Aromantic Flag"),
    AlternativeIcon(fileName: "bisexual", name: "Bisexual Flag"),
    AlternativeIcon(fileName: "gay", name: "Gay Flag"),
    AlternativeIcon(fileName: "genderfluid", name: "Genderfluid Flag"),
    AlternativeIcon(fileName: "genderqueer", name: "Genderqueer Flag"),
    AlternativeIcon(fileName: "lesbian", name: "Lesbian Flag"),
    AlternativeIcon(fileName: "nonbinary", name: "Nonbinary Flag"),
    AlternativeIcon(fileName: "pansexual", name: "Pansexual Flag"),
    AlternativeIcon(fileName: "progressive", name: "Progress Pride Flag"),
    AlternativeIcon(fileName: "transgender", name: "Transgender Flag")
]

let alternativeIconNameByPath: [String?: String] = Dictionary(uniqueKeysWithValues: alternativeElsewhenIcons.map { ($0.fileName, $0.name) })
