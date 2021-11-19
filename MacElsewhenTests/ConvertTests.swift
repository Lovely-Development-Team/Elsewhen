//
//  ConvertTests.swift
//  ConvertTests
//
//  Created by David on 09/10/2021.
//

import XCTest
@testable import Elsewhen

let timezoneUtc = TimeZone(secondsFromGMT: 0)!

class ConvertTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    static let timezonesToTest: [(String, Double)] = [
        ("Europe/Amsterdam", 2.0),
        ("America/Los_Angeles", -7.0),
        ("America/Chicago", -5.0),
        ("America/New_York", -4.0),
        ("Europe/Rome", 2.0),
        ("Asia/Damascus", 3.0),
        ("Australia/Brisbane", 10.0),
    ]

    func testConvertFromUTC() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let originalDate = Date(timeIntervalSince1970: 1633786560)
        for (timezoneIdentifier, offsetHours) in Self.timezonesToTest {
            let conversionResult = convert(date: originalDate, from: timezoneUtc, to: TimeZone(identifier: timezoneIdentifier)!)
            XCTAssertEqual(originalDate.distance(to: conversionResult), TimeInterval.oneHour * offsetHours, "\(timezoneIdentifier) should be \(offsetHours) from UTC")
        }
    }
    
    func testConvertToUTC() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let originalDate = Date(timeIntervalSince1970: 1633786560)
        for (timezoneIdentifier, offsetHours) in Self.timezonesToTest {
            let conversionResult = convert(date: originalDate, from: TimeZone(identifier: timezoneIdentifier)!, to: timezoneUtc)
            XCTAssertEqual(conversionResult.distance(to: originalDate), TimeInterval.oneHour * offsetHours, "\(timezoneIdentifier) should be \(offsetHours) from UTC")
        }
    }

}
