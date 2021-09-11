//
//  InTimeZoneExtension.swift
//  InTimeZoneExtension
//
//  Created by David on 11/09/2021.
//

import Foundation

extension INTimezone {
    convenience init(from timezone: TimeZone) {
        self.init(identifier: timezone.identifier, display: timezone.identifier.replacingOccurrences(of: "_", with: " "), pronunciationHint: nil)
        self.abbreviation = timezone.abbreviation()
        self.subtitleString = timezone.abbreviation()
    }
}
