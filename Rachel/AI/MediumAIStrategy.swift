//
//  MediumAIStrategy.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

struct MediumAIStrategy: AIStrategy {
    let name = "Medium AI"
    let description = "Plays special cards strategically, considers basic tactics"
    
    func decideMove(for player: Player, gameState: GameState) -> AIDecision {
        // Handle pending pickups first
        if gameState.pendingPickups > 0 {
            return .drawCards(gameState.pendingPickups)
        }
        
        // Find playable cards
        guard let topCard = gameState.discardPile.last else { return .drawCard }
        
        let playableCards = player.hand.cards.enumerated().compactMap { index, card in
            GameRules.canPlay(card: card, on: topCard, gameState: gameState) ? 
                (index: index, card: card) : nil
        }
        
        if playableCards.isEmpty {
            return .drawCard
        }
        
        // Check if we can stack cards
        // For each playable card, see if we have other cards of the same rank to stack
        for playableCard in playableCards {
            let rank = playableCard.card.rank
            
            // Find all cards in hand with the same rank
            let sameRankCards = player.hand.cards.enumerated().compactMap { index, card in
                card.rank == rank ? (index: index, card: card) : nil
            }
            
            if sameRankCards.count > 1 {
                // We can stack these cards - decide if we should
                let shouldStack = evaluateStacking(
                    rank: rank,
                    cardCount: sameRankCards.count,
                    handSize: player.hand.count,
                    gameState: gameState
                )
                
                if shouldStack {
                    // Make sure the playable card is first
                    var indices = sameRankCards.map { $0.index }
                    if let playableIndex = indices.firstIndex(of: playableCard.index) {
                        indices.remove(at: playableIndex)
                        indices.insert(playableCard.index, at: 0)
                    }
                    let nominateSuit = rank == .ace ? selectBestSuit(for: player) : nil
                    return .playCards(indices: indices, nominateSuit: nominateSuit)
                }
            }
        }
        
        // Single card play - use existing logic
        let chosenCard = selectBestCard(from: playableCards, player: player, gameState: gameState)
        
        // If playing an Ace, nominate the most common suit in hand
        if chosenCard.card.rank == .ace {
            let nominatedSuit = selectBestSuit(for: player, excluding: chosenCard.card.suit)
            return .playCard(index: chosenCard.index, nominateSuit: nominatedSuit)
        }
        
        return .playCard(index: chosenCard.index, nominateSuit: nil)
    }
    
    private func evaluateStacking(
        rank: Rank,
        cardCount: Int,
        handSize: Int,
        gameState: GameState
    ) -> Bool {
        // Special rules for 2s - be cautious about stacking them
        if rank == .two {
            // Count total 2s that could come back
            let potentialPickups = cardCount * 2 // Each 2 adds 2 cards
            
            // If we have many cards, don't risk it
            if handSize > 10 && potentialPickups > 4 {
                return false // Play one at a time
            }
            
            // If we're close to winning, be aggressive
            if handSize <= 4 {
                return true
            }
            
            // Otherwise, only stack if we have a backup 2
            let total2sInHand = gameState.players[gameState.currentPlayerIndex].hand.cards
                .filter { $0.rank == .two }.count
            return total2sInHand > cardCount // Keep at least one 2 in reserve
        }
        
        // For other special cards (Jacks, Queens, Aces), usually good to stack
        if [.jack, .queen, .ace].contains(rank) {
            // Stack if we're trying to reduce hand size
            return handSize > 7
        }
        
        // For normal cards, always stack when possible
        return true
    }
    
    private func selectBestCard(
        from playableCards: [(index: Int, card: Card)],
        player: Player,
        gameState: GameState
    ) -> (index: Int, card: Card) {
        // Check if any opponent has few cards
        let opponentHasFewCards = gameState.players.contains { otherPlayer in
            otherPlayer.id != player.id && otherPlayer.hand.cards.count <= 3
        }
        
        if opponentHasFewCards {
            // Prefer attack cards when opponents are close to winning
            if let twoCard = playableCards.first(where: { $0.card.rank == .two }) {
                return twoCard
            }
            if let jackCard = playableCards.first(where: { $0.card.rank == .jack }) {
                return jackCard
            }
        }
        
        // Otherwise play high value cards first to reduce hand
        return playableCards.max { first, second in
            first.card.rank.numericValue < second.card.rank.numericValue
        } ?? playableCards[0]
    }
    
    private func selectBestSuit(for player: Player, excluding: Suit? = nil) -> Suit {
        // Count suits in hand (excluding the suit we just played if any)
        let suitCounts = player.hand.cards
            .filter { excluding == nil || $0.suit != excluding }
            .reduce(into: [:]) { counts, card in
                counts[card.suit, default: 0] += 1
            }
        
        // Pick the most common suit
        if let mostCommonSuit = suitCounts.max(by: { $0.value < $1.value })?.key {
            return mostCommonSuit
        } else {
            // If no other suits, pick a random one
            let availableSuits = excluding != nil ? 
                Suit.allCases.filter { $0 != excluding } : Suit.allCases
            return availableSuits.randomElement() ?? .hearts
        }
    }
}