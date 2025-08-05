//
//  NominateSuitEffectTests.swift
//  RachelTests
//
//  Created by Steve Hill on 05/08/2025.
//

import XCTest
@testable import Rachel

final class NominateSuitEffectTests: XCTestCase {
    
    func testNominateSuitEffect() {
        var gameState = GameState(players: [Player(id: "1", name: "Test")])
        
        let effect = NominateSuitEffect()
        effect.apply(to: &gameState)
        
        XCTAssertTrue(gameState.needsSuitNomination)
        XCTAssertNil(gameState.nominatedSuit)
    }
}