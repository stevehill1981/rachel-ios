//
//  SuitTests.swift
//  RachelTests
//
//  Created by Steve Hill on 05/08/2025.
//

import XCTest
@testable import Rachel

final class SuitTests: XCTestCase {
    
    func testSuitRawValues() {
        XCTAssertEqual(Suit.hearts.rawValue, "♥️")
        XCTAssertEqual(Suit.diamonds.rawValue, "♦️")
        XCTAssertEqual(Suit.clubs.rawValue, "♣️")
        XCTAssertEqual(Suit.spades.rawValue, "♠️")
    }
    
    func testAllCases() {
        XCTAssertEqual(Suit.allCases.count, 4)
        XCTAssertTrue(Suit.allCases.contains(.hearts))
        XCTAssertTrue(Suit.allCases.contains(.diamonds))
        XCTAssertTrue(Suit.allCases.contains(.clubs))
        XCTAssertTrue(Suit.allCases.contains(.spades))
    }
}