//
//  SkipEffect.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

struct SkipEffect: CardEffect {
    func apply(to gameState: inout GameState) {
        gameState.pendingSkips += 1
    }
}