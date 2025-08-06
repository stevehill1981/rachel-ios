//
//  AIStrategyTests.swift
//  RachelTests
//
//  Created by Steve Hill on 05/08/2025.
//

import XCTest
@testable import Rachel

class AIStrategyTests: XCTestCase {
    
    func testEasyAIPlaysFirstValidCard() {
        let strategy = EasyAIStrategy()
        let player = createPlayerWithCards([
            Card(rank: .three, suit: .hearts),
            Card(rank: .seven, suit: .spades),
            Card(rank: .ace, suit: .diamonds)
        ])
        let state = createGameState(topCard: Card(rank: .seven, suit: .diamonds), players: [player])
        
        let decision = strategy.decideMove(for: player, gameState: state)
        
        if case .playCard(let index, _) = decision {
            // Easy AI plays first valid card, which should be seven of spades (matches rank)
            XCTAssertEqual(index, 1)
        } else {
            XCTFail("Expected to play a card")
        }
    }
    
    func testMediumAIPrefersPick2WhenOpponentHasFewCards() {
        let strategy = MediumAIStrategy()
        let player = createPlayerWithCards([
            Card(rank: .two, suit: .spades),
            Card(rank: .seven, suit: .spades),
            Card(rank: .king, suit: .spades)
        ], id: "player1")
        let opponent = createPlayerWithCards([Card(rank: .five, suit: .hearts)], id: "player2") // Only 1 card
        let state = createGameState(
            topCard: Card(rank: .three, suit: .spades),
            players: [player, opponent],
            currentPlayerIndex: 0
        )
        
        let decision = strategy.decideMove(for: player, gameState: state)
        
        if case .playCard(let index, _) = decision {
            // Since the opponent has only 1 card (≤ 3), it should prefer the 2
            XCTAssertEqual(index, 0) // Should play the 2 of spades
        } else {
            XCTFail("Expected to play the pick-2 card")
        }
    }
    
    func testHardAINominatesStrategicSuit() {
        let strategy = HardAIStrategy()
        let player = createPlayerWithCards([
            Card(rank: .ace, suit: .hearts),
            Card(rank: .three, suit: .spades),
            Card(rank: .three, suit: .clubs),
            Card(rank: .five, suit: .clubs),
            Card(rank: .six, suit: .clubs)
        ])
        let state = createGameState(topCard: Card(rank: .ace, suit: .diamonds), players: [player])
        
        let decision = strategy.decideMove(for: player, gameState: state)
        
        if case .playCard(let index, let nominatedSuit) = decision {
            XCTAssertEqual(index, 0) // Should play the Ace
            XCTAssertNotNil(nominatedSuit)
            // Hard AI should pick the suit they have least of to preserve flexibility
            // Player has: 0 hearts (after playing Ace), 1 spades, 3 clubs
            // Should pick spades (has only 1) or a suit they don't have at all
            XCTAssertTrue(nominatedSuit == .spades || nominatedSuit == .diamonds, 
                         "Should pick spades (has 1) or diamonds (has 0), but picked \(nominatedSuit!)")
        } else {
            XCTFail("Expected to play the Ace")
        }
    }
    
    func testAllStrategiesHandlePendingPickups() {
        let strategies: [AIStrategy] = [EasyAIStrategy(), MediumAIStrategy(), HardAIStrategy()]
        
        for strategy in strategies {
            let player = createPlayerWithCards([Card(rank: .king, suit: .hearts)])
            var state = createGameState(topCard: Card(rank: .two, suit: .spades), players: [player])
            state.pendingPickups = 2
            
            let decision = strategy.decideMove(for: player, gameState: state)
            
            if case .drawCards(let count) = decision {
                XCTAssertEqual(count, 2, "\(strategy.name) should draw pending pickups")
            } else {
                XCTFail("\(strategy.name) should draw cards when pending pickups exist")
            }
        }
    }
    
    func testAllStrategiesDrawWhenNoValidMoves() {
        let strategies: [AIStrategy] = [EasyAIStrategy(), MediumAIStrategy(), HardAIStrategy()]
        
        for strategy in strategies {
            let player = createPlayerWithCards([Card(rank: .king, suit: .hearts)])
            let state = createGameState(topCard: Card(rank: .three, suit: .clubs), players: [player])
            
            let decision = strategy.decideMove(for: player, gameState: state)
            
            if case .drawCard = decision {
                // Success
            } else {
                XCTFail("\(strategy.name) should draw when no valid moves")
            }
        }
    }
    
    // MARK: - Helpers
    
    private func createPlayerWithCards(_ cards: [Card], id: String = UUID().uuidString) -> Player {
        var player = Player(id: id, name: "Test", isAI: true)
        cards.forEach { player.hand.addCard($0) }
        return player
    }
    
    private func createGameState(topCard: Card, players: [Player], currentPlayerIndex: Int = 0) -> GameState {
        var state = GameState(players: players)
        state.discardPile = [topCard]
        state.currentPlayerIndex = currentPlayerIndex
        return state
    }
}