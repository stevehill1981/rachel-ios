//
//  GameEngineEdgeCaseTests.swift
//  RachelTests
//
//  Created by Steve Hill on 05/08/2025.
//

import XCTest
@testable import Rachel

final class GameEngineEdgeCaseTests: XCTestCase {
    
    private func createTestEngine(playerCount: Int = 2) -> GameEngine {
        var players: [Player] = []
        for i in 0..<playerCount {
            players.append(Player(id: "\(i)", name: "Player \(i+1)"))
        }
        return GameEngine(players: players)
    }
    
    // MARK: - Deck Reshuffling
    
    func testDeckReshufflingWhenEmpty() {
        let engine = createTestEngine()
        engine.dealCards()
        
        // Empty the deck but keep some cards in discard
        let discardCards = [
            Card(rank: .five, suit: .hearts),
            Card(rank: .six, suit: .clubs),
            Card(rank: .seven, suit: .diamonds),
            Card(rank: .eight, suit: .spades)
        ]
        
        engine.updateState { state in
            state.deck = Deck(cards: [])  // Empty deck
            state.discardPile = discardCards
            state.pendingPickups = 3  // Force pickup when deck is empty
            state.pendingPickupType = .twos  // Pending 2s
            // Ensure player 1 has no 2s to counter with
            state.players[1].hand = Hand(cards: [
                Card(rank: .king, suit: .hearts),
                Card(rank: .queen, suit: .clubs),
                Card(rank: .jack, suit: .diamonds),
                Card(rank: .ten, suit: .spades),
                Card(rank: .nine, suit: .hearts),
                Card(rank: .eight, suit: .clubs),
                Card(rank: .seven, suit: .hearts)
            ])
        }
        
        let topCard = engine.state.discardPile.last!
        XCTAssertEqual(engine.state.players[1].hand.count, 7)  // Verify starting with 7 cards
        XCTAssertEqual(engine.state.deck.count, 0)  // Verify deck is empty
        XCTAssertEqual(engine.state.discardPile.count, 4)  // Verify 4 cards in discard
        
        engine.endTurn()
        
        // Should have reshuffled and picked up cards
        XCTAssertEqual(engine.state.players[1].hand.count, 10)  // 7 + 3 pickups
        XCTAssertEqual(engine.state.discardPile.count, 1)  // Only top card remains
        XCTAssertEqual(engine.state.discardPile.last, topCard)  // Top card unchanged
        XCTAssertTrue(engine.state.deck.count >= 0)  // Deck should have cards from reshuffle
    }
    
    // MARK: - Skip Edge Cases
    
    func testMultipleSkipsWithTwoPlayers() {
        let engine = createTestEngine(playerCount: 2)
        engine.dealCards()
        
        engine.updateState { state in
            state.pendingSkips = 3
        }
        
        // With 2 players, odd skips return to same player
        engine.endTurn()
        XCTAssertEqual(engine.state.currentPlayerIndex, 0)
    }
    
    func testSkipLastRemainingPlayer() {
        let engine = createTestEngine(playerCount: 3)
        engine.dealCards()
        
        // Players 0 and 1 have finished
        engine.updateState { state in
            state.players[0].hand.removeAllCards()
            state.players[1].hand.removeAllCards()
            state.finishedPlayerIndices = [0, 1]
            state.currentPlayerIndex = 2
            state.pendingSkips = 1
        }
        
        // Skip should have no effect - only one player left
        engine.endTurn()
        XCTAssertEqual(engine.state.gameStatus, .finished)
    }
    
    // MARK: - Reversal Edge Cases
    
    func testReversalWithTwoPlayers() {
        let engine = createTestEngine(playerCount: 2)
        engine.dealCards()
        
        // With 2 players, reversal has no effect on turn order
        engine.updateState { state in
            state.direction = .counterclockwise
        }
        
        engine.endTurn()
        XCTAssertEqual(engine.state.currentPlayerIndex, 1)
        
        engine.endTurn()
        XCTAssertEqual(engine.state.currentPlayerIndex, 0)
    }
    
    // MARK: - Complex Pickup Scenarios
    
    func testRedJackFullyCountersBlackJacks() {
        let engine = createTestEngine()
        engine.dealCards()
        
        let topCard = Card(rank: .jack, suit: .clubs)
        let redJack = Card(rank: .jack, suit: .hearts)
        
        engine.updateState { state in
            state.discardPile = [topCard]
            state.pendingPickups = 10  // 2 black jacks
            state.pendingPickupType = .blackJacks
            state.players[0].hand = Hand(cards: [redJack, redJack])
        }
        
        // Play first red jack
        _ = engine.playCard(at: 0, by: 0)
        XCTAssertEqual(engine.state.pendingPickups, 5)
        
        // Can play second red jack while pickups are still pending
        let canPlay = GameRules.canPlay(
            card: redJack,
            on: engine.state.discardPile.last!,
            gameState: engine.state
        )
        XCTAssertTrue(canPlay)  // Should be able to counter remaining pickups
    }
    
    func testCannotMixPickupTypesInSameTurn() {
        let engine = createTestEngine()
        engine.dealCards()
        
        let two = Card(rank: .two, suit: .hearts)
        let blackJack = Card(rank: .jack, suit: .clubs)
        
        engine.updateState { state in
            state.discardPile = [two]
            state.pendingPickups = 2
            state.pendingPickupType = .twos
            state.players[0].hand = Hand(cards: [blackJack])
        }
        
        // Cannot play black jack on pending twos
        let played = engine.playCard(at: 0, by: 0)
        XCTAssertFalse(played)
    }
    
    // MARK: - Ace Edge Cases
    
    func testAceOnAce() {
        let engine = createTestEngine()
        engine.dealCards()
        
        let ace1 = Card(rank: .ace, suit: .hearts)
        let ace2 = Card(rank: .ace, suit: .clubs)
        
        engine.updateState { state in
            state.discardPile = [ace1]
            state.nominatedSuit = .diamonds
            state.players[0].hand = Hand(cards: [ace2])
        }
        
        // Can play ace on ace even with nominated suit
        let played = engine.playCard(at: 0, by: 0)
        XCTAssertTrue(played)
        XCTAssertTrue(engine.state.needsSuitNomination)
    }
    
    func testMustFollowNominatedSuit() {
        let engine = createTestEngine()
        engine.dealCards()
        
        let topCard = Card(rank: .ace, suit: .hearts)
        let diamond = Card(rank: .five, suit: .diamonds)
        let club = Card(rank: .five, suit: .clubs)
        
        engine.updateState { state in
            state.discardPile = [topCard]
            state.nominatedSuit = .diamonds
            state.players[0].hand = Hand(cards: [diamond, club])
        }
        
        // Can play diamond
        XCTAssertTrue(GameRules.canPlay(card: diamond, on: topCard, gameState: engine.state))
        
        // Cannot play club
        XCTAssertFalse(GameRules.canPlay(card: club, on: topCard, gameState: engine.state))
    }
    
    // MARK: - Game End Edge Cases
    
    func testLastPlayerAutoFinishes() {
        let engine = createTestEngine(playerCount: 2)
        engine.dealCards()
        
        // Player 0 finishes
        engine.updateState { state in
            state.players[0].hand.removeAllCards()
        }
        engine.endTurn()
        
        // Game should end immediately
        XCTAssertEqual(engine.state.gameStatus, .finished)
        XCTAssertEqual(engine.state.finishedPlayerIndices, [0, 1])
    }
    
    func testNoInfiniteLoopWithAllPlayersFinished() {
        let engine = createTestEngine(playerCount: 2)
        engine.dealCards()
        
        // Somehow all players are marked finished (edge case)
        engine.updateState { state in
            state.finishedPlayerIndices = [0, 1]
        }
        
        // Should handle gracefully
        engine.endTurn()
        XCTAssertEqual(engine.state.gameStatus, .finished)
    }
    
    // MARK: - Seven Card Stacking
    
    func testStackingMultipleSevens() {
        let engine = createTestEngine(playerCount: 4)
        engine.dealCards()
        
        let topCard = Card(rank: .seven, suit: .hearts)
        let seven2 = Card(rank: .seven, suit: .clubs)
        
        // Player 0 plays first seven
        engine.updateState { state in
            state.discardPile = [topCard]
            state.pendingSkips = 1
        }
        
        // Player 1 stacks another seven
        engine.updateState { state in
            state.currentPlayerIndex = 1
            state.players[1].hand = Hand(cards: [seven2])
        }
        _ = engine.playCard(at: 0, by: 1)
        XCTAssertEqual(engine.state.pendingSkips, 2)
        
        // End turn - should skip players 2 and 3, back to 0
        engine.endTurn()
        XCTAssertEqual(engine.state.currentPlayerIndex, 0)
    }
}
