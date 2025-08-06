//
//  GameEngineTests.swift
//  RachelTests
//
//  Created by Steve Hill on 05/08/2025.
//

import XCTest
@testable import Rachel

final class GameEngineTests: XCTestCase {
    
    private func createTestEngine(playerCount: Int = 2) -> GameEngine {
        var players: [Player] = []
        for i in 0..<playerCount {
            players.append(Player(id: "\(i)", name: "Player \(i+1)"))
        }
        return GameEngine(players: players)
    }
    
    // MARK: - Game Setup
    
    func testInitialState() {
        let engine = createTestEngine()
        
        XCTAssertEqual(engine.state.players.count, 2)
        XCTAssertEqual(engine.state.currentPlayerIndex, 0)
        XCTAssertEqual(engine.state.direction, .clockwise)
        XCTAssertEqual(engine.state.gameStatus, .notStarted)
        XCTAssertTrue(engine.state.discardPile.isEmpty)
        XCTAssertTrue(engine.state.finishedPlayerIndices.isEmpty)
    }
    
    func testDealCards() {
        let engine = createTestEngine(playerCount: 3)
        engine.dealCards()
        
        // Each player should have 7 cards
        XCTAssertEqual(engine.state.players[0].hand.count, 7)
        XCTAssertEqual(engine.state.players[1].hand.count, 7)
        XCTAssertEqual(engine.state.players[2].hand.count, 7)
        
        // Should have one card in discard pile
        XCTAssertEqual(engine.state.discardPile.count, 1)
        
        // Game should be playing
        XCTAssertEqual(engine.state.gameStatus, .playing)
        
        // Deck should have remaining cards (52 - 21 - 1 = 30)
        XCTAssertEqual(engine.state.deck.count, 30)
    }
    
    // MARK: - Basic Play
    
    func testPlayValidCard() {
        let engine = createTestEngine()
        engine.dealCards()
        
        // Set up a known game state
        let topCard = Card(rank: .five, suit: .hearts)
        let matchingCard = Card(rank: .five, suit: .clubs)
        
        engine.updateState { state in
            state.discardPile = [topCard]
            state.players[0].hand = Hand(cards: [matchingCard])
        }
        
        // Play the card
        let played = engine.playCard(at: 0, by: 0)
        
        XCTAssertTrue(played)
        XCTAssertEqual(engine.state.discardPile.last, matchingCard)
        XCTAssertTrue(engine.state.players[0].hand.isEmpty)
    }
    
    func testCannotPlayInvalidCard() {
        let engine = createTestEngine()
        engine.dealCards()
        
        // Set up a known game state
        let topCard = Card(rank: .five, suit: .hearts)
        let nonMatchingCard = Card(rank: .king, suit: .clubs)
        
        engine.updateState { state in
            state.discardPile = [topCard]
            state.players[0].hand = Hand(cards: [nonMatchingCard])
        }
        
        // Try to play the card
        let played = engine.playCard(at: 0, by: 0)
        
        XCTAssertFalse(played)
        XCTAssertEqual(engine.state.discardPile.last, topCard)
        XCTAssertEqual(engine.state.players[0].hand.count, 1)
    }
    
    func testCannotPlayOutOfTurn() {
        let engine = createTestEngine()
        engine.dealCards()
        
        let topCard = Card(rank: .five, suit: .hearts)
        let validCard = Card(rank: .five, suit: .clubs)
        
        engine.updateState { state in
            state.discardPile = [topCard]
            state.players[1].hand = Hand(cards: [validCard])
        }
        
        // Try to play when it's player 1's turn
        let played = engine.playCard(at: 0, by: 1)
        
        XCTAssertFalse(played)
    }
    
    // MARK: - Turn Management
    
    func testEndTurnAdvancesPlayer() {
        let engine = createTestEngine(playerCount: 3)
        engine.dealCards()
        
        XCTAssertEqual(engine.state.currentPlayerIndex, 0)
        
        engine.endTurn()
        XCTAssertEqual(engine.state.currentPlayerIndex, 1)
        
        engine.endTurn()
        XCTAssertEqual(engine.state.currentPlayerIndex, 2)
        
        engine.endTurn()
        XCTAssertEqual(engine.state.currentPlayerIndex, 0)
    }
    
    func testEndTurnWithReverse() {
        let engine = createTestEngine(playerCount: 3)
        engine.dealCards()
        
        // Start at player 0, going clockwise
        XCTAssertEqual(engine.state.currentPlayerIndex, 0)
        
        // Reverse direction
        engine.updateState { state in
            state.direction = .counterclockwise
        }
        
        engine.endTurn()
        XCTAssertEqual(engine.state.currentPlayerIndex, 2) // 0 -> 2 (counterclockwise)
        
        engine.endTurn()
        XCTAssertEqual(engine.state.currentPlayerIndex, 1) // 2 -> 1
        
        engine.endTurn()
        XCTAssertEqual(engine.state.currentPlayerIndex, 0) // 1 -> 0
    }
    
    // MARK: - Special Effects
    
    func testTwoEffect() {
        let engine = createTestEngine()
        engine.dealCards()
        
        let topCard = Card(rank: .five, suit: .hearts)
        let two = Card(rank: .two, suit: .hearts)
        
        engine.updateState { state in
            state.discardPile = [topCard]
            state.players[0].hand = Hand(cards: [two])
            // Ensure player 1 has no 2s to counter
            state.players[1].hand = Hand(cards: [
                Card(rank: .king, suit: .hearts),
                Card(rank: .queen, suit: .clubs),
                Card(rank: .jack, suit: .diamonds),
                Card(rank: .ten, suit: .spades),
                Card(rank: .nine, suit: .hearts),
                Card(rank: .eight, suit: .clubs),
                Card(rank: .three, suit: .hearts)
            ])
        }
        
        _ = engine.playCard(at: 0, by: 0)
        
        // Should have pending pickups
        XCTAssertEqual(engine.state.pendingPickups, 2)
        XCTAssertEqual(engine.state.pendingPickupType, .twos)
        
        // End turn - player 1 should pick up cards
        let player1InitialCards = engine.state.players[1].hand.count
        engine.endTurn()
        
        XCTAssertEqual(engine.state.players[1].hand.count, player1InitialCards + 2)
        XCTAssertEqual(engine.state.pendingPickups, 0)
        XCTAssertNil(engine.state.pendingPickupType)
    }
    
    func testQueenReversal() {
        let engine = createTestEngine(playerCount: 4)
        engine.dealCards()
        
        let topCard = Card(rank: .five, suit: .hearts)
        let queen = Card(rank: .queen, suit: .hearts)
        
        engine.updateState { state in
            state.discardPile = [topCard]
            state.players[0].hand = Hand(cards: [queen])
        }
        
        XCTAssertEqual(engine.state.direction, .clockwise)
        _ = engine.playCard(at: 0, by: 0)
        XCTAssertEqual(engine.state.direction, .counterclockwise)
        
        // End turn should go to player 3 (not player 1)
        engine.endTurn()
        XCTAssertEqual(engine.state.currentPlayerIndex, 3)
    }
    
    // MARK: - Win Conditions
    
    func testPlayerFinishing() {
        let engine = createTestEngine(playerCount: 3)
        engine.dealCards()
        
        // Empty player 1's hand
        engine.updateState { state in
            state.players[0].hand.removeAllCards()
        }
        
        engine.endTurn()
        
        // Player 1 should be in finished list
        XCTAssertEqual(engine.state.finishedPlayerIndices, [0])
        
        // Game should still be playing
        XCTAssertEqual(engine.state.gameStatus, .playing)
        
        // Turn should skip player 1
        XCTAssertEqual(engine.state.currentPlayerIndex, 1)
        
        engine.endTurn()
        XCTAssertEqual(engine.state.currentPlayerIndex, 2)
        
        engine.endTurn()
        XCTAssertEqual(engine.state.currentPlayerIndex, 1) // Skips 0
    }
    
    func testGameEnd() {
        let engine = createTestEngine(playerCount: 3)
        engine.dealCards()
        
        // Players 0 and 1 finish
        engine.updateState { state in
            state.players[0].hand.removeAllCards()
        }
        engine.endTurn()
        
        engine.updateState { state in
            state.players[1].hand.removeAllCards()
            state.currentPlayerIndex = 1
        }
        engine.endTurn()
        
        // Only player 2 left
        XCTAssertEqual(engine.state.gameStatus, .finished)
        XCTAssertEqual(engine.state.finishedPlayerIndices, [0, 1, 2])
    }
    
    // MARK: - Suit Nomination
    
    func testAceNomination() {
        let engine = createTestEngine()
        engine.dealCards()
        
        let topCard = Card(rank: .five, suit: .hearts)
        let ace = Card(rank: .ace, suit: .hearts)
        
        engine.updateState { state in
            state.discardPile = [topCard]
            state.players[0].hand = Hand(cards: [ace])
        }
        
        _ = engine.playCard(at: 0, by: 0)
        
        XCTAssertTrue(engine.state.needsSuitNomination)
        
        // Nominate a suit
        engine.nominateSuit(.diamonds)
        
        XCTAssertEqual(engine.state.nominatedSuit, .diamonds)
        XCTAssertFalse(engine.state.needsSuitNomination)
    }
    
    // MARK: - Custom Game Setup
    
    func testCustomGameSetup() {
        // Create players with different AI difficulties
        let players = [
            Player(id: "1", name: "Human Player"),
            Player(id: "2", name: "Easy AI", isAI: true, aiSkillLevel: .easy),
            Player(id: "3", name: "Medium AI", isAI: true, aiSkillLevel: .medium),
            Player(id: "4", name: "Hard AI", isAI: true, aiSkillLevel: .hard)
        ]
        
        let engine = GameEngine(players: [])
        
        // Setup new game
        engine.setupNewGame(players: players)
        
        // Verify players were set correctly
        XCTAssertEqual(engine.state.players.count, 4)
        XCTAssertEqual(engine.state.players[0].name, "Human Player")
        XCTAssertFalse(engine.state.players[0].isAI)
        
        XCTAssertEqual(engine.state.players[1].name, "Easy AI")
        XCTAssertTrue(engine.state.players[1].isAI)
        XCTAssertEqual(engine.state.players[1].aiSkillLevel, .easy)
        
        XCTAssertEqual(engine.state.players[2].name, "Medium AI")
        XCTAssertTrue(engine.state.players[2].isAI)
        XCTAssertEqual(engine.state.players[2].aiSkillLevel, .medium)
        
        XCTAssertEqual(engine.state.players[3].name, "Hard AI")
        XCTAssertTrue(engine.state.players[3].isAI)
        XCTAssertEqual(engine.state.players[3].aiSkillLevel, .hard)
        
        // Verify game state is reset
        XCTAssertEqual(engine.state.currentPlayerIndex, 0)
        XCTAssertEqual(engine.state.gameStatus, .notStarted)
        XCTAssertTrue(engine.state.discardPile.isEmpty)
    }
    
    func testCustomGameWithMixedDifficulties() {
        // Create 7 AI players with mixed difficulties
        let players = [
            Player(id: "1", name: "Human"),
            Player(id: "2", name: "AI 1", isAI: true, aiSkillLevel: .easy),
            Player(id: "3", name: "AI 2", isAI: true, aiSkillLevel: .hard),
            Player(id: "4", name: "AI 3", isAI: true, aiSkillLevel: .medium),
            Player(id: "5", name: "AI 4", isAI: true, aiSkillLevel: .easy),
            Player(id: "6", name: "AI 5", isAI: true, aiSkillLevel: .hard),
            Player(id: "7", name: "AI 6", isAI: true, aiSkillLevel: .medium),
            Player(id: "8", name: "AI 7", isAI: true, aiSkillLevel: .hard)
        ]
        
        let engine = GameEngine(players: [])
        engine.setupNewGame(players: players)
        
        XCTAssertEqual(engine.state.players.count, 8)
        
        // Count difficulties
        let easyCount = engine.state.players.filter { $0.aiSkillLevel == .easy }.count
        let mediumCount = engine.state.players.filter { $0.aiSkillLevel == .medium }.count
        let hardCount = engine.state.players.filter { $0.aiSkillLevel == .hard }.count
        
        XCTAssertEqual(easyCount, 2)
        XCTAssertEqual(mediumCount, 2)
        XCTAssertEqual(hardCount, 3)
    }
    
    func testDealCardsAfterCustomSetup() {
        let players = [
            Player(id: "1", name: "Player 1"),
            Player(id: "2", name: "Player 2", isAI: true)
        ]
        
        let engine = GameEngine(players: [])
        engine.setupNewGame(players: players)
        engine.dealCards()
        
        // Verify cards were dealt
        XCTAssertEqual(engine.state.players[0].hand.count, 7)
        XCTAssertEqual(engine.state.players[1].hand.count, 7)
        XCTAssertEqual(engine.state.discardPile.count, 1)
        XCTAssertEqual(engine.state.gameStatus, .playing)
    }
    
    // MARK: - Multiple Card Play
    
    func testPlayMultipleCardsSuccess() {
        let players = [
            Player(id: "1", name: "Player 1"),
            Player(id: "2", name: "Player 2")
        ]
        
        var state = GameState(players: players)
        state.currentPlayerIndex = 0
        
        // Give player three 7s
        state.players[0].hand.addCard(Card(rank: .seven, suit: .hearts))
        state.players[0].hand.addCard(Card(rank: .seven, suit: .diamonds))
        state.players[0].hand.addCard(Card(rank: .seven, suit: .clubs))
        state.players[0].hand.addCard(Card(rank: .king, suit: .spades))
        
        // Top card is a 7 of spades
        state.discardPile = [Card(rank: .seven, suit: .spades)]
        state.gameStatus = .playing
        
        let engine = GameEngine(state: state)
        
        // Play all three 7s
        let success = engine.playMultipleCards(indices: [0, 1, 2], by: 0)
        
        XCTAssertTrue(success)
        XCTAssertEqual(engine.state.players[0].hand.count, 1) // Only King left
        XCTAssertEqual(engine.state.discardPile.count, 4) // Original + 3 played
    }
    
    func testPlayMultipleCardsInvalidRank() {
        let players = [
            Player(id: "1", name: "Player 1"),
            Player(id: "2", name: "Player 2")
        ]
        
        var state = GameState(players: players)
        state.currentPlayerIndex = 0
        
        // Give player mixed ranks
        state.players[0].hand.addCard(Card(rank: .seven, suit: .hearts))
        state.players[0].hand.addCard(Card(rank: .seven, suit: .diamonds))
        state.players[0].hand.addCard(Card(rank: .eight, suit: .clubs))
        
        // Top card
        state.discardPile = [Card(rank: .seven, suit: .spades)]
        state.gameStatus = .playing
        
        let engine = GameEngine(state: state)
        
        // Try to play cards with different ranks
        let success = engine.playMultipleCards(indices: [0, 1, 2], by: 0)
        
        XCTAssertFalse(success)
        XCTAssertEqual(engine.state.players[0].hand.count, 3) // No cards removed
    }
    
    func testPlayMultipleCardsFirstNotPlayable() {
        let players = [
            Player(id: "1", name: "Player 1"),
            Player(id: "2", name: "Player 2")
        ]
        
        var state = GameState(players: players)
        state.currentPlayerIndex = 0
        
        // Give player three 7s
        state.players[0].hand.addCard(Card(rank: .seven, suit: .hearts))
        state.players[0].hand.addCard(Card(rank: .seven, suit: .diamonds))
        state.players[0].hand.addCard(Card(rank: .seven, suit: .clubs))
        
        // Top card is a King (7s can't be played)
        state.discardPile = [Card(rank: .king, suit: .spades)]
        state.gameStatus = .playing
        
        let engine = GameEngine(state: state)
        
        // Try to play the 7s
        let success = engine.playMultipleCards(indices: [0, 1, 2], by: 0)
        
        XCTAssertFalse(success)
        XCTAssertEqual(engine.state.players[0].hand.count, 3) // No cards removed
    }
}
