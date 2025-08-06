//
//  GameState.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

import Foundation

struct GameState {
    // Core game components
    var players: [Player]
    var deck: Deck
    var discardPile: [Card] = []
    
    // Game flow
    var currentPlayerIndex: Int = 0
    var direction: Direction = .clockwise
    var gameStatus: GameStatus = .notStarted
    var finishedPlayerIndices: [Int] = [] // Order of finishing (1st, 2nd, 3rd, etc.)
    var turnCount: Int = 0 // Track total turns played
    
    // Pending effects
    var pendingPickups: Int = 0
    var pendingPickupType: PickupType?
    var pendingSkips: Int = 0
    var nominatedSuit: Suit?
    var needsSuitNomination: Bool = false
    
    init(players: [Player], deck: Deck = Deck()) {
        self.players = players
        self.deck = deck
    }
}