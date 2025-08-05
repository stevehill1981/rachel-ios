//
//  Hand.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

struct Hand {
    private(set) var cards: [Card] = []
    
    init() {
        self.cards = []
    }
    
    // Test helper - only use in tests
    #if DEBUG
    init(cards: [Card]) {
        self.cards = cards
    }
    #endif
    
    mutating func addCard(_ card: Card) {
        cards.append(card)
    }
    
    mutating func removeCard(at index: Int) -> Card? {
        guard index >= 0 && index < cards.count else {
            return nil
        }
        
        return cards.remove(at: index)
    }
    
    mutating func removeAllCards() {
        cards.removeAll()
    }
    
    var count: Int {
        return cards.count
    }
    
    var isEmpty: Bool {
        return cards.isEmpty
    }
}
