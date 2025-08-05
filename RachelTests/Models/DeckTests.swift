//
//  DeckTests.swift
//  RachelTests
//
//  Created by Steve Hill on 05/08/2025.
//

import XCTest
@testable import Rachel

final class DeckTests: XCTestCase {
    
    func testDeckInitialization() {
        let deck = Deck()
        XCTAssertEqual(deck.count, 52, "A new deck should have 52 cards")
        XCTAssertFalse(deck.isEmpty)
    }
    
    func testDeckContainsAllCards() {
        let deck = Deck()
        
        // Verify we have 4 suits × 13 ranks = 52 unique cards
        var uniqueCards = Set<String>()
        for card in deck.cards {
            let cardString = "\(card.rank.rawValue)\(card.suit.rawValue)"
            uniqueCards.insert(cardString)
        }
        
        XCTAssertEqual(uniqueCards.count, 52, "Deck should contain 52 unique cards")
    }
    
    func testDeckDeal() {
        var deck = Deck()
        let initialCount = deck.count
        
        let dealtCard = deck.deal()
        
        XCTAssertNotNil(dealtCard)
        XCTAssertEqual(deck.count, initialCount - 1)
    }
    
    func testDealingAllCards() {
        var deck = Deck()
        var dealtCards: [Card] = []
        
        // Deal all 52 cards
        while let card = deck.deal() {
            dealtCards.append(card)
        }
        
        XCTAssertEqual(dealtCards.count, 52)
        XCTAssertTrue(deck.isEmpty)
        XCTAssertNil(deck.deal(), "Dealing from empty deck should return nil")
    }
    
    func testDeckIsShuffled() {
        // Create multiple decks and verify they're not in the same order
        let deck1 = Deck()
        let deck2 = Deck()
        
        // It's extremely unlikely two shuffled decks are identical
        // But there's a tiny chance, so we just check they exist
        XCTAssertEqual(deck1.count, 52)
        XCTAssertEqual(deck2.count, 52)
        
        // For a more robust test, we could check that cards aren't in perfect suit/rank order
        var inPerfectOrder = true
        _ = deck1.cards.first!
        
        for (index, suit) in Suit.allCases.enumerated() {
            for (rankIndex, rank) in Rank.allCases.enumerated() {
                let cardIndex = index * 13 + rankIndex
                if cardIndex < deck1.cards.count {
                    let card = deck1.cards[cardIndex]
                    if card.suit != suit || card.rank != rank {
                        inPerfectOrder = false
                        break
                    }
                }
            }
            if !inPerfectOrder { break }
        }
        
        XCTAssertFalse(inPerfectOrder, "Deck should be shuffled, not in perfect order")
    }
}