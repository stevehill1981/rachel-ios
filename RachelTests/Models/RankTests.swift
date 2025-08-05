//
//  RankTests.swift
//  RachelTests
//
//  Created by Steve Hill on 05/08/2025.
//

import XCTest
@testable import Rachel

final class RankTests: XCTestCase {
    
    func testRankRawValues() {
        XCTAssertEqual(Rank.two.rawValue, "2")
        XCTAssertEqual(Rank.three.rawValue, "3")
        XCTAssertEqual(Rank.four.rawValue, "4")
        XCTAssertEqual(Rank.five.rawValue, "5")
        XCTAssertEqual(Rank.six.rawValue, "6")
        XCTAssertEqual(Rank.seven.rawValue, "7")
        XCTAssertEqual(Rank.eight.rawValue, "8")
        XCTAssertEqual(Rank.nine.rawValue, "9")
        XCTAssertEqual(Rank.ten.rawValue, "10")
        XCTAssertEqual(Rank.jack.rawValue, "J")
        XCTAssertEqual(Rank.queen.rawValue, "Q")
        XCTAssertEqual(Rank.king.rawValue, "K")
        XCTAssertEqual(Rank.ace.rawValue, "A")
    }
    
    func testAllCases() {
        XCTAssertEqual(Rank.allCases.count, 13)
        
        // Verify order is maintained
        let expectedOrder: [Rank] = [.two, .three, .four, .five, .six, .seven, .eight, .nine, .ten, .jack, .queen, .king, .ace]
        XCTAssertEqual(Rank.allCases, expectedOrder)
    }
}