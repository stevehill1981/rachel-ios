//
//  Player.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

struct Player: Identifiable {
    let id: String
    let name: String
    var hand: Hand = Hand()
    let isAI: Bool
    
    init(id: String, name: String, isAI: Bool = false) {
        self.id = id
        self.name = name
        self.isAI = isAI
    }
}
