//
//  CardEffectFactoryTests.swift
//  RachelTests
//
//  Created by Steve Hill on 05/08/2025.
//

import XCTest
@testable import Rachel

final class CardEffectFactoryTests: XCTestCase {
    
    func testTwoCreatesPickUpEffect() {
        let card = Card(rank: .two, suit: .hearts)
        let effect = CardEffectFactory.effect(for: card)
        
        XCTAssertTrue(effect is PickUpEffect)
        if let pickUp = effect as? PickUpEffect {
            XCTAssertEqual(pickUp.count, 2)
            XCTAssertEqual(pickUp.type, .twos)
        }
    }
    
    func testSevenCreatesSkipEffect() {
        let card = Card(rank: .seven, suit: .diamonds)
        let effect = CardEffectFactory.effect(for: card)
        
        XCTAssertTrue(effect is SkipEffect)
    }
    
    func testQueenCreatesReverseEffect() {
        let card = Card(rank: .queen, suit: .clubs)
        let effect = CardEffectFactory.effect(for: card)
        
        XCTAssertTrue(effect is ReverseEffect)
    }
    
    func testBlackJackCreatesJackEffect() {
        let clubJack = Card(rank: .jack, suit: .clubs)
        let spadeJack = Card(rank: .jack, suit: .spades)
        
        let effect1 = CardEffectFactory.effect(for: clubJack)
        let effect2 = CardEffectFactory.effect(for: spadeJack)
        
        XCTAssertTrue(effect1 is JackEffect)
        XCTAssertTrue(effect2 is JackEffect)
        
        if let jack1 = effect1 as? JackEffect {
            XCTAssertTrue(jack1.isBlack)
        }
    }
    
    func testRedJackCreatesJackEffect() {
        let heartJack = Card(rank: .jack, suit: .hearts)
        let diamondJack = Card(rank: .jack, suit: .diamonds)
        
        let effect1 = CardEffectFactory.effect(for: heartJack)
        let effect2 = CardEffectFactory.effect(for: diamondJack)
        
        XCTAssertTrue(effect1 is JackEffect)
        XCTAssertTrue(effect2 is JackEffect)
        
        if let jack1 = effect1 as? JackEffect {
            XCTAssertFalse(jack1.isBlack)
        }
    }
    
    func testAceCreatesNominateSuitEffect() {
        let card = Card(rank: .ace, suit: .spades)
        let effect = CardEffectFactory.effect(for: card)
        
        XCTAssertTrue(effect is NominateSuitEffect)
    }
    
    func testNormalCardHasNoEffect() {
        let normalCards = [
            Card(rank: .three, suit: .hearts),
            Card(rank: .four, suit: .diamonds),
            Card(rank: .five, suit: .clubs),
            Card(rank: .six, suit: .spades),
            Card(rank: .eight, suit: .hearts),
            Card(rank: .nine, suit: .diamonds),
            Card(rank: .ten, suit: .clubs),
            Card(rank: .king, suit: .spades)
        ]
        
        for card in normalCards {
            XCTAssertNil(CardEffectFactory.effect(for: card))
        }
    }
}