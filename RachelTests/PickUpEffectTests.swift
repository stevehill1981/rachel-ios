//
//  PickUpEffectTests.swift
//  RachelTests
//
//  Created by Steve Hill on 05/08/2025.
//

import XCTest
@testable import Rachel

final class PickUpEffectTests: XCTestCase {
    
    func testTwoEffect() {
        var gameState = GameState(players: [Player(id: "1", name: "Test")])
        let effect = PickUpEffect(count: 2, type: .twos)
        
        effect.apply(to: &gameState)
        
        XCTAssertEqual(gameState.pendingPickups, 2)
        XCTAssertEqual(gameState.pendingPickupType, .twos)
    }
    
    func testStackingTwos() {
        var gameState = GameState(players: [Player(id: "1", name: "Test")])
        
        // First two
        let effect1 = PickUpEffect(count: 2, type: .twos)
        effect1.apply(to: &gameState)
        
        // Second two
        let effect2 = PickUpEffect(count: 2, type: .twos)
        effect2.apply(to: &gameState)
        
        XCTAssertEqual(gameState.pendingPickups, 4)
        XCTAssertEqual(gameState.pendingPickupType, .twos)
    }
    
    func testCannotMixPickupTypes() {
        var gameState = GameState(players: [Player(id: "1", name: "Test")])
        
        // Apply twos first
        let twoEffect = PickUpEffect(count: 2, type: .twos)
        twoEffect.apply(to: &gameState)
        XCTAssertEqual(gameState.pendingPickups, 2)
        
        // Try to apply black jack - should not work
        let blackJackEffect = PickUpEffect(count: 5, type: .blackJacks)
        blackJackEffect.apply(to: &gameState)
        
        // Should still be 2 (not 7)
        XCTAssertEqual(gameState.pendingPickups, 2)
        XCTAssertEqual(gameState.pendingPickupType, .twos)
    }
}