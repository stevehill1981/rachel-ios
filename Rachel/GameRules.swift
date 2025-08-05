//
//  GameRules.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

struct GameRules {
    static func canPlay(card: Card, on topCard: Card, gameState: GameState) -> Bool {
        // If there's a nominated suit, must play that suit or an Ace
        if let suit = gameState.nominatedSuit {
            return card.suit == suit || card.rank == .ace
        }
        
        // If there are pending pickups, check if we can counter/stack
        if let pickupType = gameState.pendingPickupType, gameState.pendingPickups > 0 {
            switch pickupType {
            case .twos:
                // Can only play another 2 to stack
                return card.rank == .two
            case .blackJacks:
                // Can play any Jack (black to stack, red to counter)
                return card.rank == .jack
            }
        }
        
        // If there are pending skips, must match rank or suit
        // (Skips don't prevent normal play rules)
        
        // Standard rule: match rank or suit
        return card.rank == topCard.rank || card.suit == topCard.suit
    }
}