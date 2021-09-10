//
//  INFormatCodeExtension.swift
//  INFormatCodeExtension
//
//  Created by David on 10/09/2021.
//

import Foundation

extension FormatCode {
    init?(from inFormatCode: INFormatCode) {
        switch inFormatCode {
        case .unknown:
            return nil
        case .full:
            self = .f
        case .fullWithDay:
            self = .F
        case .dateOnly:
            self = .D
        case .timeOnly:
            self = .t
        case .timeWithSeconds:
            self = .T
        case .relative:
            self = .R
        }
    }
}
