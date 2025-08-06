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
    
    func testAIPlayerSkillLevel() {
        // Human player should have nil skill level
        let human = Player(id: "1", name: "Human")
        XCTAssertNil(human.aiSkillLevel)
        
        // AI player without specified skill level defaults to medium
        let defaultAI = Player(id: "2", name: "AI", isAI: true)
        XCTAssertEqual(defaultAI.aiSkillLevel, .medium)
        
        // AI player with specified skill level
        let easyAI = Player(id: "3", name: "Easy AI", isAI: true, aiSkillLevel: .easy)
        XCTAssertEqual(easyAI.aiSkillLevel, .easy)
        
        let hardAI = Player(id: "4", name: "Hard AI", isAI: true, aiSkillLevel: .hard)
        XCTAssertEqual(hardAI.aiSkillLevel, .hard)
    }
    
    func testNonAIPlayerIgnoresSkillLevel() {
        // Even if skill level is provided, non-AI players should have nil
        let human = Player(id: "1", name: "Human", isAI: false, aiSkillLevel: .hard)
        XCTAssertNil(human.aiSkillLevel)
    }
}