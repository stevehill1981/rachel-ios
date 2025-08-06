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
        
        // Group cards by rank to find stackable options
        let cardsByRank = Dictionary(grouping: playableCards) { $0.card.rank }
        
        // Easy AI: If we can stack cards, always do it
        for (rank, cards) in cardsByRank {
            if cards.count > 1 {
                // Stack all cards of this rank
                let indices = cards.map { $0.index }
                let nominateSuit = rank == .ace ? 
                    Suit.allCases.filter { $0 != cards[0].card.suit }.randomElement() ?? .hearts : nil
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