//
//  HandTests.swift
//  RachelTests
//
//  Created by Steve Hill on 05/08/2025.
//

import XCTest
@testable import Rachel

final class HandTests: XCTestCase {
    
    func testHandInitialization() {
        let hand = Hand()
        XCTAssertTrue(hand.isEmpty)
        XCTAssertEqual(hand.count, 0)
    }
    
    func testAddCard() {
        var hand = Hand()
        let card = Card(rank: .ace, suit: .spades)
        
        hand.addCard(card)
        
        XCTAssertEqual(hand.count, 1)
        XCTAssertFalse(hand.isEmpty)
        XCTAssertEqual(hand.cards.first, card)
    }
    
    func testAddMultipleCards() {
        var hand = Hand()
        let cards = [
            Card(rank: .ace, suit: .spades),
            Card(rank: .king, suit: .hearts),
            Card(rank: .queen, suit: .diamonds)
        ]
        
        for card in cards {
            hand.addCard(card)
        }
        
        XCTAssertEqual(hand.count, 3)
        XCTAssertEqual(hand.cards, cards)
    }
    
    func testRemoveCard() {
        var hand = Hand()
        let card1 = Card(rank: .ace, suit: .spades)
        let card2 = Card(rank: .king, suit: .hearts)
        
        hand.addCard(card1)
        hand.addCard(card2)
        
        let removedCard = hand.removeCard(at: 0)
        
        XCTAssertEqual(removedCard, card1)
        XCTAssertEqual(hand.count, 1)
        XCTAssertEqual(hand.cards.first, card2)
    }
    
    func testRemoveCardInvalidIndex() {
        var hand = Hand()
        hand.addCard(Card(rank: .ace, suit: .spades))
        
        XCTAssertNil(hand.removeCard(at: -1))
        XCTAssertNil(hand.removeCard(at: 5))
        XCTAssertEqual(hand.count, 1) // Card should still be there
    }
    
    func testRemoveAllCards() {
        var hand = Hand()
        for suit in Suit.allCases {
            hand.addCard(Card(rank: .ace, suit: suit))
        }
        
        XCTAssertEqual(hand.count, 4)
        
        while !hand.isEmpty {
            _ = hand.removeCard(at: 0)
        }
        
        XCTAssertTrue(hand.isEmpty)
        XCTAssertEqual(hand.count, 0)
    }
}