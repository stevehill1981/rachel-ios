//
//  GameStatusTests.swift
//  RachelTests
//
//  Created by Steve Hill on 05/08/2025.
//

import XCTest
@testable import Rachel

final class GameStatusTests: XCTestCase {
    
    func testGameStatusCases() {
        let notStarted = GameStatus.notStarted
        let playing = GameStatus.playing
        let finished = GameStatus.finished
        
        // Just verify all cases exist and are distinct
        XCTAssertNotEqual(notStarted, playing)
        XCTAssertNotEqual(playing, finished)
        XCTAssertNotEqual(notStarted, finished)
    }
}