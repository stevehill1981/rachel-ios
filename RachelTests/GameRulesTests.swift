//
//  GameRulesTests.swift
//  RachelTests
//
//  Created by Steve Hill on 05/08/2025.
//

import XCTest
@testable import Rachel

final class GameRulesTests: XCTestCase {
    
    // MARK: - Basic Rules
    
    func testCanPlayMatchingRank() {
        let gameState = GameState(players: [Player(id: "1", name: "Test")])
        let topCard = Card(rank: .five, suit: .hearts)
        let playCard = Card(rank: .five, suit: .clubs)
        
        XCTAssertTrue(GameRules.canPlay(card: playCard, on: topCard, gameState: gameState))
    }
    
    func testCanPlayMatchingSuit() {
        let gameState = GameState(players: [Player(id: "1", name: "Test")])
        let topCard = Card(rank: .five, suit: .hearts)
        let playCard = Card(rank: .king, suit: .hearts)
        
        XCTAssertTrue(GameRules.canPlay(card: playCard, on: topCard, gameState: gameState))
    }
    
    func testCannotPlayNonMatching() {
        let gameState = GameState(players: [Player(id: "1", name: "Test")])
        let topCard = Card(rank: .five, suit: .hearts)
        let playCard = Card(rank: .king, suit: .clubs)
        
        XCTAssertFalse(GameRules.canPlay(card: playCard, on: topCard, gameState: gameState))
    }
    
    // MARK: - Nominated Suit Rules
    
    func testMustPlayNominatedSuit() {
        var gameState = GameState(players: [Player(id: "1", name: "Test")])
        gameState.nominatedSuit = .diamonds
        
        let topCard = Card(rank: .ace, suit: .hearts)
        let diamondCard = Card(rank: .three, suit: .diamonds)
        let nonDiamondCard = Card(rank: .three, suit: .clubs)
        
        XCTAssertTrue(GameRules.canPlay(card: diamondCard, on: topCard, gameState: gameState))
        XCTAssertFalse(GameRules.canPlay(card: nonDiamondCard, on: topCard, gameState: gameState))
    }
    
    func testAceCanBePlayedOnNominatedSuit() {
        var gameState = GameState(players: [Player(id: "1", name: "Test")])
        gameState.nominatedSuit = .diamonds
        
        let topCard = Card(rank: .five, suit: .hearts)
        let ace = Card(rank: .ace, suit: .clubs)
        
        XCTAssertTrue(GameRules.canPlay(card: ace, on: topCard, gameState: gameState))
    }
    
    // MARK: - Pickup Rules
    
    func testCanStackTwos() {
        var gameState = GameState(players: [Player(id: "1", name: "Test")])
        gameState.pendingPickups = 2
        gameState.pendingPickupType = .twos
        
        let topCard = Card(rank: .two, suit: .hearts)
        let anotherTwo = Card(rank: .two, suit: .clubs)
        let notTwo = Card(rank: .five, suit: .hearts)
        
        XCTAssertTrue(GameRules.canPlay(card: anotherTwo, on: topCard, gameState: gameState))
        XCTAssertFalse(GameRules.canPlay(card: notTwo, on: topCard, gameState: gameState))
    }
    
    func testCannotPlayJackOnTwo() {
        var gameState = GameState(players: [Player(id: "1", name: "Test")])
        gameState.pendingPickups = 2
        gameState.pendingPickupType = .twos
        
        let topCard = Card(rank: .two, suit: .hearts)
        let jack = Card(rank: .jack, suit: .clubs)
        
        XCTAssertFalse(GameRules.canPlay(card: jack, on: topCard, gameState: gameState))
    }
    
    func testCanPlayAnyJackOnBlackJack() {
        var gameState = GameState(players: [Player(id: "1", name: "Test")])
        gameState.pendingPickups = 5
        gameState.pendingPickupType = .blackJacks
        
        let topCard = Card(rank: .jack, suit: .clubs)
        let blackJack = Card(rank: .jack, suit: .spades)
        let redJack = Card(rank: .jack, suit: .hearts)
        let notJack = Card(rank: .king, suit: .clubs)
        
        XCTAssertTrue(GameRules.canPlay(card: blackJack, on: topCard, gameState: gameState))
        XCTAssertTrue(GameRules.canPlay(card: redJack, on: topCard, gameState: gameState))
        XCTAssertFalse(GameRules.canPlay(card: notJack, on: topCard, gameState: gameState))
    }
    
    func testCannotPlayTwoOnBlackJack() {
        var gameState = GameState(players: [Player(id: "1", name: "Test")])
        gameState.pendingPickups = 5
        gameState.pendingPickupType = .blackJacks
        
        let topCard = Card(rank: .jack, suit: .clubs)
        let two = Card(rank: .two, suit: .hearts)
        
        XCTAssertFalse(GameRules.canPlay(card: two, on: topCard, gameState: gameState))
    }
}