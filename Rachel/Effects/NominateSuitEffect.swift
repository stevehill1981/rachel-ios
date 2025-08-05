//
//  NominateSuitEffect.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

struct NominateSuitEffect: CardEffect {
    func apply(to gameState: inout GameState) {
        // This just marks that nomination is needed
        // The actual nomination happens through a separate method
        gameState.needsSuitNomination = true
    }
}