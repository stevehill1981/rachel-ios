//
//  PickupTypeTests.swift
//  RachelTests
//
//  Created by Steve Hill on 05/08/2025.
//

import XCTest
@testable import Rachel

final class PickupTypeTests: XCTestCase {
    
    func testPickupTypes() {
        let twos = PickupType.twos
        let blackJacks = PickupType.blackJacks
        
        XCTAssertNotEqual(twos, blackJacks)
    }
}