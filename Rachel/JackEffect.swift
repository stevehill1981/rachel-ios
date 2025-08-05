//
//  JackEffect.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

struct JackEffect: CardEffect {
    let suit: Suit
    
    var isBlack: Bool {
        suit == .clubs || suit == .spades
    }
    
    func apply(to gameState: inout GameState) {
        if isBlack {
            // Black jack adds 5 pickups
            gameState.pendingPickups += 5
            gameState.pendingPickupType = .blackJacks
        } else {
            // Red jack counters black jacks
            if gameState.pendingPickupType == .blackJacks && gameState.pendingPickups > 0 {
                // Reduce pickups by 5 (countering one black jack)
                gameState.pendingPickups = max(0, gameState.pendingPickups - 5)
                
                // If no pickups remain, clear the pickup type
                if gameState.pendingPickups == 0 {
                    gameState.pendingPickupType = nil
                }
            }
            // If played as a normal card (not on black jack pickups), no effect
        }
    }
}