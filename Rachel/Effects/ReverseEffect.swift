//
//  ReverseEffect.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

struct ReverseEffect: CardEffect {
    func apply(to gameState: inout GameState) {
        gameState.direction = (gameState.direction == .clockwise) ? .counterclockwise : .clockwise
    }
}