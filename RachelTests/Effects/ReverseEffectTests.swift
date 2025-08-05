//
//  ReverseEffectTests.swift
//  RachelTests
//
//  Created by Steve Hill on 05/08/2025.
//

import XCTest
@testable import Rachel

final class ReverseEffectTests: XCTestCase {
    
    func testReverseFromClockwise() {
        var gameState = GameState(players: [Player(id: "1", name: "Test")])
        gameState.direction = .clockwise
        
        let reverse = ReverseEffect()
        reverse.apply(to: &gameState)
        
        XCTAssertEqual(gameState.direction, .counterclockwise)
    }
    
    func testReverseFromCounterclockwise() {
        var gameState = GameState(players: [Player(id: "1", name: "Test")])
        gameState.direction = .counterclockwise
        
        let reverse = ReverseEffect()
        reverse.apply(to: &gameState)
        
        XCTAssertEqual(gameState.direction, .clockwise)
    }
    
    func testDoubleReverse() {
        var gameState = GameState(players: [Player(id: "1", name: "Test")])
        let originalDirection = gameState.direction
        
        ReverseEffect().apply(to: &gameState)
        ReverseEffect().apply(to: &gameState)
        
        XCTAssertEqual(gameState.direction, originalDirection)
    }
}