//
//  AIPlayer.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

struct AIPlayer {
    let skillLevel: AISkillLevel
    private let strategy: AIStrategy
    
    init(skillLevel: AISkillLevel = .medium) {
        self.skillLevel = skillLevel
        self.strategy = skillLevel.strategy
    }
    
    func decideMove(for player: Player, gameState: GameState) -> AIDecision {
        return strategy.decideMove(for: player, gameState: gameState)
    }
    
    // Legacy static method for backwards compatibility
    static func decideMove(for player: Player, gameState: GameState) -> AIDecision {
        // Default to medium difficulty
        let aiPlayer = AIPlayer(skillLevel: .medium)
        return aiPlayer.decideMove(for: player, gameState: gameState)
    }
}