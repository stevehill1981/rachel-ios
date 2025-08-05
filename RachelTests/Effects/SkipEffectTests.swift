//
//  SkipEffectTests.swift
//  RachelTests
//
//  Created by Steve Hill on 05/08/2025.
//

import XCTest
@testable import Rachel

final class SkipEffectTests: XCTestCase {
    
    func testSkipEffect() {
        var gameState = GameState(players: [Player(id: "1", name: "Test")])
        
        let skip = SkipEffect()
        skip.apply(to: &gameState)
        
        XCTAssertEqual(gameState.pendingSkips, 1)
    }
    
    func testStackingSkips() {
        var gameState = GameState(players: [Player(id: "1", name: "Test")])
        
        SkipEffect().apply(to: &gameState)
        SkipEffect().apply(to: &gameState)
        SkipEffect().apply(to: &gameState)
        
        XCTAssertEqual(gameState.pendingSkips, 3)
    }
}