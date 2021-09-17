//
//  Bundle.swift
//  Bundle
//
//  Created by David Stephens on 17/09/2021.
//

import Foundation

extension Bundle {
    static var displayName: String {
        let bundleDisplayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName")
        return (bundleDisplayName ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName"))  as! String
    }
}
