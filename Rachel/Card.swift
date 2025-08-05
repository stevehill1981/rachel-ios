//
//  Card.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

import Foundation

struct Card: Identifiable, Equatable, Hashable {
    let rank: Rank
    let suit: Suit
    
    // Computed property for ID based on rank and suit
    var id: String {
        "\(rank.rawValue)-\(suit.rawValue)"
    }
    
    init(rank: Rank, suit: Suit) {
        self.rank = rank
        self.suit = suit
    }
}
