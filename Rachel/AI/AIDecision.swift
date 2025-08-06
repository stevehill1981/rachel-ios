//
//  AIDecision.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

enum AIDecision {
    case playCard(index: Int, nominateSuit: Suit?)
    case playCards(indices: [Int], nominateSuit: Suit?)  // Play multiple cards
    case drawCard
    case drawCards(Int)
}