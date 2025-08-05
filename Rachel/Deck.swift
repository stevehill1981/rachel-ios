//
//  Deck.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

struct Deck {
    private(set) var cards: [Card]
    
    init() {
        var newCards: [Card] = []
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                newCards.append(Card(rank: rank, suit: suit))
            }
        }
        self.cards = newCards.shuffled()
    }
    
    mutating func deal() -> Card? {
        return cards.popLast()
    }
    
    var isEmpty: Bool {
        return cards.isEmpty
    }
    
    var count: Int {
        return cards.count
    }
}
