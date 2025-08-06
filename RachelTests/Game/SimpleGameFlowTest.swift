//
//  SimpleGameFlowTest.swift
//  RachelTests
//
//  Created by Steve Hill on 05/08/2025.
//

import XCTest
@testable import Rachel

final class SimpleGameFlowTest: XCTestCase {
    
    func testBasicGameFlow() {
        // Simple 2-player game
        let players = [
            Player(id: "p1", name: "Player 1"),
            Player(id: "p2", name: "AI Player", isAI: true, aiSkillLevel: .easy)
        ]
        
        var engine = GameEngine(players: players)
        engine.dealCards()
        
        XCTAssertEqual(engine.state.gameStatus, .playing)
        XCTAssertEqual(engine.state.currentPlayerIndex, 0)
        
        // Test a few turns
        for turn in 0..<10 {
            print("Turn \(turn):")
            GameTestHelper.executeTurn(for: &engine, printDebug: true)
            
            // Verify game state is still valid
            XCTAssertTrue(engine.state.currentPlayerIndex >= 0 && engine.state.currentPlayerIndex < engine.state.players.count)
            XCTAssertTrue(engine.state.discardPile.count > 0, "Discard pile should never be empty")
        }
        
        print("After 10 turns, game status: \(engine.state.gameStatus)")
    }
    
    func testAICanPlayValidCards() {
        let players = [
            Player(id: "ai", name: "AI", isAI: true)
        ]
        
        let engine = GameEngine(players: players)
        
        // Set up a specific game state
        engine.updateState { state in
            state.deck = Deck()
            state.discardPile = [Card(rank: .seven, suit: .hearts)]
            
            // Give AI some cards including valid ones
            state.players[0].hand.removeAllCards()
            state.players[0].hand.addCard(Card(rank: .seven, suit: .spades)) // Valid - matches rank
            state.players[0].hand.addCard(Card(rank: .three, suit: .hearts)) // Valid - matches suit
            state.players[0].hand.addCard(Card(rank: .king, suit: .clubs)) // Invalid
        }
        
        let aiPlayer = AIPlayer(skillLevel: .easy)
        let decision = aiPlayer.decideMove(for: engine.state.players[0], gameState: engine.state)
        
        // AI should choose to play a card
        if case .playCard(let index, _) = decision {
            XCTAssertTrue(index == 0 || index == 1, "AI should choose one of the valid cards")
        } else {
            XCTFail("AI should play a card when valid options exist")
        }
    }
}
