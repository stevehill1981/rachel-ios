//
//  GameEngine.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

struct GameEngine {
    private(set) var state: GameState
    
    init(players: [Player]) {
        self.state = GameState(players: players)
    }
    
    // Test helper
    #if DEBUG
    init(state: GameState) {
        self.state = state
    }
    
    mutating func updateState(_ closure: (inout GameState) -> Void) {
        closure(&state)
    }
    #endif
    
    // MARK: - Game Setup
    
    mutating func dealCards(cardsPerPlayer: Int = 7) {
        for _ in 0..<cardsPerPlayer {
            for playerIndex in state.players.indices {
                if let card = state.deck.deal() {
                    state.players[playerIndex].hand.addCard(card)
                }
            }
        }
        
        // Deal first card to discard pile
        if let firstCard = state.deck.deal() {
            state.discardPile.append(firstCard)
        }
        
        state.gameStatus = .playing
    }
    
    // MARK: - Playing Cards
    
    mutating func playCard(at cardIndex: Int, by playerIndex: Int) -> Bool {
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
    
    // MARK: - Turn Management
    
    mutating func endTurn() {
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
    
    mutating func nominateSuit(_ suit: Suit) {
        guard state.needsSuitNomination else { return }
        state.nominatedSuit = suit
        state.needsSuitNomination = false
    }
    
    // MARK: - Private Helpers
    
    private mutating func moveToNextPlayer() {
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
    
    private mutating func pickupCards(count: Int) {
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
    
    private mutating func reshuffleDeck() {
        guard state.discardPile.count > 1 else { return }
        
        // Keep the top card
        let topCard = state.discardPile.removeLast()
        
        // Shuffle the rest back into deck
        state.deck = Deck(cards: state.discardPile.shuffled())
        
        // Reset discard pile with just the top card
        state.discardPile = [topCard]
    }
    
    private mutating func checkForGameEnd() {
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
}