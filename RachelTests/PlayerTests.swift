//
//  PlayerTests.swift
//  RachelTests
//
//  Created by Steve Hill on 05/08/2025.
//

import XCTest
@testable import Rachel

final class PlayerTests: XCTestCase {
    
    func testPlayerInitialization() {
        let player = Player(id: "1", name: "Test Player")
        
        XCTAssertEqual(player.id, "1")
        XCTAssertEqual(player.name, "Test Player")
        XCTAssertFalse(player.isAI)
        XCTAssertTrue(player.hand.isEmpty)
    }
    
    func testAIPlayerInitialization() {
        let aiPlayer = Player(id: "2", name: "AI Player", isAI: true)
        
        XCTAssertEqual(aiPlayer.id, "2")
        XCTAssertEqual(aiPlayer.name, "AI Player")
        XCTAssertTrue(aiPlayer.isAI)
        XCTAssertTrue(aiPlayer.hand.isEmpty)
    }
    
    func testPlayerWithCards() {
        var player = Player(id: "1", name: "Test Player")
        
        player.hand.addCard(Card(rank: .ace, suit: .spades))
        player.hand.addCard(Card(rank: .king, suit: .hearts))
        
        XCTAssertEqual(player.hand.count, 2)
        XCTAssertFalse(player.hand.isEmpty)
    }
}