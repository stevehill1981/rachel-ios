//
//  CardTests.swift
//  RachelTests
//
//  Created by Steve Hill on 05/08/2025.
//

import XCTest
@testable import Rachel

final class CardTests: XCTestCase {
    
    func testCardInitialization() {
        let card = Card(rank: .ace, suit: .spades)
        XCTAssertEqual(card.rank, .ace)
        XCTAssertEqual(card.suit, .spades)
        XCTAssertNotNil(card.id)
    }
    
    func testCardEquality() {
        let card1 = Card(rank: .ace, suit: .spades)
        let card2 = Card(rank: .ace, suit: .spades)
        let card3 = Card(rank: .king, suit: .hearts)
        
        // Cards with same rank and suit should be equal
        XCTAssertEqual(card1, card2)
        XCTAssertNotEqual(card1, card3)
    }
    
    func testCardHashable() {
        let card1 = Card(rank: .ace, suit: .spades)
        let card2 = Card(rank: .ace, suit: .spades)
        let card3 = Card(rank: .king, suit: .hearts)
        
        var cardSet = Set<Card>()
        cardSet.insert(card1)
        cardSet.insert(card2)
        cardSet.insert(card3)
        
        // Set should contain 2 cards (card1 and card2 are equal)
        XCTAssertEqual(cardSet.count, 2)
    }
}