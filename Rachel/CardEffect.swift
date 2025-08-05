//
//  CardEffect.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

protocol CardEffect {
    func apply(to gameState: inout GameState)
}