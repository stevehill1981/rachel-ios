//
//  PickUpEffect.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

struct PickUpEffect: CardEffect {
    let count: Int
    let type: PickupType
    
    func apply(to gameState: inout GameState) {
        // Only apply if no pickups are pending or if it's the same type
        if gameState.pendingPickupType == nil || gameState.pendingPickupType == type {
            gameState.pendingPickups += count
            gameState.pendingPickupType = type
        }
        // If different type, this card can't be played (should be caught by game rules)
    }
}