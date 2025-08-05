//
//  Player.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

struct Player: Identifiable {
    let id: String
    let name: String
    var hand: Hand
    let isAI: Bool
    
    init(id: String, name: String, isAI: Bool = false) {
        self.id = id
        self.name = name
        self.isAI = isAI
        self.hand = Hand()
    }
    
    // Test helper
    #if DEBUG
    init(id: String, name: String, hand: Hand, isAI: Bool = false) {
        self.id = id
        self.name = name
        self.hand = hand
        self.isAI = isAI
    }
    #endif
}
