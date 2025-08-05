//
//  DirectionTests.swift
//  RachelTests
//
//  Created by Steve Hill on 05/08/2025.
//

import XCTest
@testable import Rachel

final class DirectionTests: XCTestCase {
    
    func testDirectionCases() {
        let clockwise = Direction.clockwise
        let counterclockwise = Direction.counterclockwise
        
        XCTAssertNotEqual(clockwise, counterclockwise)
    }
}