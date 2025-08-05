//
//  JackEffectTests.swift
//  RachelTests
//
//  Created by Steve Hill on 05/08/2025.
//

import XCTest
@testable import Rachel

final class JackEffectTests: XCTestCase {
    
    func testBlackJackAddsPickups() {
        var gameState = GameState(players: [Player(id: "1", name: "Test")])
        
        let blackJack = JackEffect(suit: .clubs)
        blackJack.apply(to: &gameState)
        
        XCTAssertEqual(gameState.pendingPickups, 5)
        XCTAssertEqual(gameState.pendingPickupType, .blackJacks)
    }
    
    func testStackingBlackJacks() {
        var gameState = GameState(players: [Player(id: "1", name: "Test")])
        
        let jack1 = JackEffect(suit: .clubs)
        jack1.apply(to: &gameState)
        
        let jack2 = JackEffect(suit: .spades)
        jack2.apply(to: &gameState)
        
        XCTAssertEqual(gameState.pendingPickups, 10)
        XCTAssertEqual(gameState.pendingPickupType, .blackJacks)
    }
    
    func testRedJackCountersBlackJack() {
        var gameState = GameState(players: [Player(id: "1", name: "Test")])
        
        // Play black jack first
        let blackJack = JackEffect(suit: .clubs)
        blackJack.apply(to: &gameState)
        XCTAssertEqual(gameState.pendingPickups, 5)
        
        // Play red jack to counter
        let redJack = JackEffect(suit: .hearts)
        redJack.apply(to: &gameState)
        
        XCTAssertEqual(gameState.pendingPickups, 0)
        XCTAssertNil(gameState.pendingPickupType)
    }
    
    func testRedJackCountersMultipleBlackJacks() {
        var gameState = GameState(players: [Player(id: "1", name: "Test")])
        
        // Play two black jacks
        JackEffect(suit: .clubs).apply(to: &gameState)
        JackEffect(suit: .spades).apply(to: &gameState)
        XCTAssertEqual(gameState.pendingPickups, 10)
        
        // One red jack reduces by 5
        JackEffect(suit: .hearts).apply(to: &gameState)
        XCTAssertEqual(gameState.pendingPickups, 5)
        XCTAssertEqual(gameState.pendingPickupType, .blackJacks)
        
        // Another red jack clears it
        JackEffect(suit: .diamonds).apply(to: &gameState)
        XCTAssertEqual(gameState.pendingPickups, 0)
        XCTAssertNil(gameState.pendingPickupType)
    }
    
    func testRedJackAsNormalCard() {
        var gameState = GameState(players: [Player(id: "1", name: "Test")])
        
        // Play red jack with no pending pickups
        let redJack = JackEffect(suit: .hearts)
        redJack.apply(to: &gameState)
        
        // Should have no effect
        XCTAssertEqual(gameState.pendingPickups, 0)
        XCTAssertNil(gameState.pendingPickupType)
    }
}