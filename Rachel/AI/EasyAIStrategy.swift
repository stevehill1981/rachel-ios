//
//  EasyAIStrategy.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

struct EasyAIStrategy: AIStrategy {
    let name = "Easy AI"
    let description = "Plays the first valid card found, no strategic thinking"
    
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
        
        // Easy AI: Check if we can stack cards
        // For each playable card, see if we have other cards of the same rank to stack
        for playableCard in playableCards {
            let rank = playableCard.card.rank
            
            // Find all cards in hand with the same rank
            let sameRankCards = player.hand.cards.enumerated().compactMap { index, card in
                card.rank == rank ? (index: index, card: card) : nil
            }
            
            if sameRankCards.count > 1 {
                // Stack all cards of this rank
                // Make sure the playable card is first
                var indices = sameRankCards.map { $0.index }
                if let playableIndex = indices.firstIndex(of: playableCard.index) {
                    indices.remove(at: playableIndex)
                    indices.insert(playableCard.index, at: 0)
                }
                let nominateSuit = rank == .ace ? 
                    Suit.allCases.filter { $0 != sameRankCards[0].card.suit }.randomElement() ?? .hearts : nil
                return .playCards(indices: indices, nominateSuit: nominateSuit)
            }
        }
        
        // Otherwise just play the first valid card
        let chosenCard = playableCards[0]
        
        // If playing an Ace, pick a random suit
        if chosenCard.card.rank == .ace {
            let availableSuits = Suit.allCases.filter { $0 != chosenCard.card.suit }
            let nominatedSuit = availableSuits.randomElement() ?? .hearts
            return .playCard(index: chosenCard.index, nominateSuit: nominatedSuit)
        }
        
        return .playCard(index: chosenCard.index, nominateSuit: nil)
    }
}