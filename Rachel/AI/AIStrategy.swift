//
//  AIStrategy.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

protocol AIStrategy {
    var name: String { get }
    var description: String { get }
    
    func decideMove(for player: Player, gameState: GameState) -> AIDecision
}