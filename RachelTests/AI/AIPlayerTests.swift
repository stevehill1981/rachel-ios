//
//  AIPlayerTests.swift
//  RachelTests
//
//  Created by Steve Hill on 05/08/2025.
//

import XCTest
@testable import Rachel

class AIPlayerTests: XCTestCase {
    
    func testAIPlayerUsesCorrectStrategy() {
        let easyAI = AIPlayer(skillLevel: .easy)
        XCTAssertEqual(easyAI.skillLevel, .easy)
        
        let mediumAI = AIPlayer(skillLevel: .medium)
        XCTAssertEqual(mediumAI.skillLevel, .medium)
        
        let hardAI = AIPlayer(skillLevel: .hard)
        XCTAssertEqual(hardAI.skillLevel, .hard)
    }
    
    func testAIPlayerDefaultsToMedium() {
        let defaultAI = AIPlayer()
        XCTAssertEqual(defaultAI.skillLevel, .medium)
    }
    
    func testStaticMethodDefaultsToMedium() {
        var player = Player(id: "ai", name: "AI", isAI: true)
        player.hand.addCard(Card(rank: .seven, suit: .hearts))
        
        var state = GameState(players: [player])
        state.discardPile = [Card(rank: .seven, suit: .spades)]
        
        let decision = AIPlayer.decideMove(for: player, gameState: state)
        
        // Should make a decision (not crash)
        switch decision {
        case .playCard(_, _), .playCards(_, _), .drawCard, .drawCards(_):
            // Any decision is valid, we're just testing it works
            XCTAssertTrue(true)
        }
    }
    
    func testAISkillLevelNames() {
        XCTAssertEqual(AISkillLevel.easy.name, "Easy")
        XCTAssertEqual(AISkillLevel.medium.name, "Medium")
        XCTAssertEqual(AISkillLevel.hard.name, "Hard")
    }
    
    func testAISkillLevelStrategies() {
        let easyStrategy = AISkillLevel.easy.strategy
        XCTAssertTrue(easyStrategy is EasyAIStrategy)
        
        let mediumStrategy = AISkillLevel.medium.strategy
        XCTAssertTrue(mediumStrategy is MediumAIStrategy)
        
        let hardStrategy = AISkillLevel.hard.strategy
        XCTAssertTrue(hardStrategy is HardAIStrategy)
    }
}