//
//  GameEngine.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

import SwiftUI

class GameEngine: ObservableObject {
    @Published private(set) var state: GameState
    
    init(players: [Player]) {
        self.state = GameState(players: players)
    }
    
    // Test helper - available in tests
    init(state: GameState) {
        self.state = state
    }
    
    func updateState(_ closure: (inout GameState) -> Void) {
        closure(&state)
    }
    
    // MARK: - Game Setup
    
    func dealCards(cardsPerPlayer: Int = 7) {
        for _ in 0..<cardsPerPlayer {
            for playerIndex in state.players.indices {
                if let card = state.deck.deal() {
                    state.players[playerIndex].hand.addCard(card)
                }
            }
        }
        
        // Deal first card to discard pile
        // Special cards are allowed but their effects don't apply for the first card
        if let firstCard = state.deck.deal() {
            state.discardPile.append(firstCard)
        }
        
        state.gameStatus = .playing
    }
    
    // MARK: - Playing Cards
    
    func drawCard() {
        // Check if player has any valid moves - can only draw if no playable cards
        if state.pendingPickups == 0 && playerHasValidMove() {
            // Player has valid moves - cannot draw!
            return
        }
        
        // Handle pending pickups
        if state.pendingPickups > 0 {
            pickupCards(count: state.pendingPickups)
            state.pendingPickups = 0
        } else {
            pickupCards(count: 1)
        }
        // End turn after drawing (this will handle moveToNextPlayer)
        endTurn()
    }
    
    func canPlay(card: Card, playerIndex: Int) -> Bool {
        guard playerIndex == state.currentPlayerIndex else { return false }
        guard let topCard = state.discardPile.last else { return false }
        return GameRules.canPlay(card: card, on: topCard, gameState: state)
    }
    
    func playCard(at cardIndex: Int, by playerIndex: Int) -> Bool {
        guard playerIndex == state.currentPlayerIndex else { return false }
        guard cardIndex >= 0 && cardIndex < state.players[playerIndex].hand.cards.count else { return false }
        guard let topCard = state.discardPile.last else { return false }
        
        let card = state.players[playerIndex].hand.cards[cardIndex]
        guard GameRules.canPlay(card: card, on: topCard, gameState: state) else { return false }
        
        // Remove card from hand and add to discard pile
        if let playedCard = state.players[playerIndex].hand.removeCard(at: cardIndex) {
            state.discardPile.append(playedCard)
            
            // Apply card effect
            if let effect = CardEffectFactory.effect(for: playedCard) {
                effect.apply(to: &state)
            }
            
            return true
        }
        
        return false
    }
    
    func playMultipleCards(indices: [Int], by playerIndex: Int) -> Bool {
        guard playerIndex == state.currentPlayerIndex else { return false }
        guard !indices.isEmpty else { return false }
        
        // Sort indices to play from lowest to highest
        let sortedIndices = indices.sorted()
        
        // Validate first card can be played normally
        guard sortedIndices[0] < state.players[playerIndex].hand.cards.count else { return false }
        let firstCard = state.players[playerIndex].hand.cards[sortedIndices[0]]
        guard let topCard = state.discardPile.last else { return false }
        guard GameRules.canPlay(card: firstCard, on: topCard, gameState: state) else { return false }
        
        // Validate all cards have the same rank
        let rank = firstCard.rank
        for index in sortedIndices {
            guard index < state.players[playerIndex].hand.cards.count else { return false }
            if state.players[playerIndex].hand.cards[index].rank != rank {
                return false
            }
        }
        
        // Play all cards
        var remainingIndices = sortedIndices
        var playedAny = false
        
        while !remainingIndices.isEmpty {
            let index = remainingIndices.removeFirst()
            if let playedCard = state.players[playerIndex].hand.removeCard(at: index) {
                state.discardPile.append(playedCard)
                
                // Apply card effect
                if let effect = CardEffectFactory.effect(for: playedCard) {
                    effect.apply(to: &state)
                }
                
                playedAny = true
                // Adjust remaining indices since we removed a card
                remainingIndices = remainingIndices.map { $0 > index ? $0 - 1 : $0 }
            }
        }
        
        return playedAny
    }
    
    // MARK: - Turn Management
    
    func endTurn() {
        // Increment turn count
        state.turnCount += 1
        
        // Clear turn state
        state.nominatedSuit = nil
        state.needsSuitNomination = false
        
        // Check if this player just won (emptied their hand)
        if state.players[state.currentPlayerIndex].hand.isEmpty {
            // Mark this player as finished
            state.finishedPlayerIndices.append(state.currentPlayerIndex)
        }
        
        // Move to next player (skipping finished players)
        moveToNextPlayer()
        
        // Apply skips
        while state.pendingSkips > 0 {
            state.pendingSkips -= 1
            moveToNextPlayer()
        }
        
        // Check if next player must pick up (no valid counters available)
        if state.pendingPickups > 0 {
            if !playerHasValidMove() {
                // No valid moves, must pick up
                pickupCards(count: state.pendingPickups)
                state.pendingPickups = 0
                state.pendingPickupType = nil
                // Note: Their turn will begin, and they'll need to draw or play
            }
            // If they have valid moves, they MUST play one on their turn
        }
        
        // Check if game should end
        checkForGameEnd()
    }
    
    // Check if current player has any valid moves
    func playerHasValidMove() -> Bool {
        guard let topCard = state.discardPile.last else { return false }
        let currentPlayer = state.players[state.currentPlayerIndex]
        
        for card in currentPlayer.hand.cards {
            if GameRules.canPlay(card: card, on: topCard, gameState: state) {
                return true
            }
        }
        return false
    }
    
    func nominateSuit(_ suit: Suit) {
        guard state.needsSuitNomination else { return }
        state.nominatedSuit = suit
        state.needsSuitNomination = false
    }
    
    // MARK: - Private Helpers
    
    private func moveToNextPlayer() {
        // Safety check: if all players are finished, don't loop
        if state.finishedPlayerIndices.count >= state.players.count {
            return
        }
        
        repeat {
            if state.direction == .clockwise {
                state.currentPlayerIndex = (state.currentPlayerIndex + 1) % state.players.count
            } else {
                state.currentPlayerIndex = (state.currentPlayerIndex - 1 + state.players.count) % state.players.count
            }
        } while state.finishedPlayerIndices.contains(state.currentPlayerIndex) && state.gameStatus == .playing
        // Skip players who have already finished
    }
    
    private func pickupCards(count: Int) {
        for _ in 0..<count {
            if let card = state.deck.deal() {
                state.players[state.currentPlayerIndex].hand.addCard(card)
            } else {
                // Deck is empty, reshuffle
                reshuffleDeck()
                if let card = state.deck.deal() {
                    state.players[state.currentPlayerIndex].hand.addCard(card)
                }
            }
        }
    }
    
    private func reshuffleDeck() {
        guard state.discardPile.count > 1 else { 
            print("WARNING: Cannot reshuffle - not enough cards in discard pile")
            return 
        }
        
        print("Reshuffling deck: \(state.discardPile.count - 1) cards from discard pile")
        
        // Keep the top card
        let topCard = state.discardPile.removeLast()
        
        // Shuffle the rest back into deck
        state.deck = Deck(cards: state.discardPile.shuffled())
        
        // Reset discard pile with just the top card
        state.discardPile = [topCard]
        
        print("Reshuffle complete: Deck has \(state.deck.count) cards, discard has \(state.discardPile.count) card")
    }
    
    private func checkForGameEnd() {
        // Game ends when all but one player have finished
        let playersWithCards = state.players.indices.filter { !state.finishedPlayerIndices.contains($0) }
        
        if playersWithCards.count <= 1 {
            state.gameStatus = .finished
            // The last remaining player (if any) is also added to finished list as the last place
            if let lastPlayer = playersWithCards.first {
                state.finishedPlayerIndices.append(lastPlayer)
            }
        }
    }
    
    func resetGame() {
        // Reset all players' hands
        for i in state.players.indices {
            state.players[i].hand = Hand()
        }
        
        // Reset game state
        state.deck = Deck()
        state.discardPile = []
        state.currentPlayerIndex = 0
        state.direction = .clockwise
        state.pendingPickups = 0
        state.pendingPickupType = nil
        state.pendingSkips = 0
        state.nominatedSuit = nil
        state.needsSuitNomination = false
        state.gameStatus = .notStarted
        state.finishedPlayerIndices = []
    }
    
    func setupNewGame(players: [Player]) {
        // Create a new game state with new players
        self.state = GameState(players: players)
    }
}