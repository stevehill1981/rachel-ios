//
//  AITurnCoordinator.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

import SwiftUI

class AITurnCoordinator: ObservableObject {
    @Published var aiThinkingPlayerIndex: Int? = nil
    @Published var aiSelectedCardIndex: Int? = nil
    
    private weak var engine: GameEngine?
    private var turnTimer: Timer?
    
    init(engine: GameEngine) {
        self.engine = engine
    }
    
    func startMonitoring() {
        // Check immediately and then whenever the game state changes
        checkForAITurn()
    }
    
    func stopMonitoring() {
        turnTimer?.invalidate()
        turnTimer = nil
    }
    
    func checkForAITurn() {
        guard let engine = engine,
              engine.state.gameStatus == .playing,
              engine.state.currentPlayerIndex < engine.state.players.count,
              engine.state.players[engine.state.currentPlayerIndex].isAI else {
            aiThinkingPlayerIndex = nil
            aiSelectedCardIndex = nil
            return
        }
        
        // Set AI as "thinking"
        aiThinkingPlayerIndex = engine.state.currentPlayerIndex
        
        // Schedule AI turn with natural delay
        turnTimer?.invalidate()
        turnTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
            self?.executeAITurn()
        }
    }
    
    private func executeAITurn() {
        guard let engine = engine,
              engine.state.gameStatus == .playing,
              engine.state.currentPlayerIndex < engine.state.players.count else {
            return
        }
        
        let currentPlayer = engine.state.players[engine.state.currentPlayerIndex]
        guard currentPlayer.isAI else { return }
        
        let aiPlayer = AIPlayer(skillLevel: currentPlayer.aiSkillLevel ?? .medium)
        let decision = aiPlayer.decideMove(for: currentPlayer, gameState: engine.state)
        
        // Add a small delay before executing the move for visual effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.executeDecision(decision)
        }
    }
    
    private func executeDecision(_ decision: AIDecision) {
        guard engine != nil else { return }
        
        // Show which card AI selected (if playing a card)
        switch decision {
        case .playCard(let index, _):
            aiSelectedCardIndex = index
            
            // Show the selection briefly before playing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.performDecision(decision)
            }
            
        case .playCards(let indices, _):
            // For multiple cards, show the first one
            aiSelectedCardIndex = indices.first
            
            // Show the selection briefly before playing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.performDecision(decision)
            }
            
        default:
            // For drawing, execute immediately
            performDecision(decision)
        }
    }
    
    private func performDecision(_ decision: AIDecision) {
        guard let engine = engine else { return }
        
        switch decision {
        case .playCard(let index, let nominatedSuit):
            let played = engine.playCard(at: index, by: engine.state.currentPlayerIndex)
            if played {
                if let suit = nominatedSuit, engine.state.needsSuitNomination {
                    engine.nominateSuit(suit)
                }
                engine.endTurn()
            }
            
        case .playCards(let indices, let nominatedSuit):
            // Play multiple cards in order (highest index first to maintain indices)
            let sortedIndices = indices.sorted(by: >)
            var playedAny = false
            
            for index in sortedIndices {
                if engine.playCard(at: index, by: engine.state.currentPlayerIndex) {
                    playedAny = true
                }
            }
            
            if playedAny {
                if let suit = nominatedSuit, engine.state.needsSuitNomination {
                    engine.nominateSuit(suit)
                }
                engine.endTurn()
            }
            
        case .drawCard:
            engine.drawCard()
            
        case .drawCards(_):
            // drawCard already handles pending pickups
            engine.drawCard()
        }
        
        // Clear the visual indicators
        aiThinkingPlayerIndex = nil
        aiSelectedCardIndex = nil
        
        // Check if next player is also AI
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.checkForAITurn()
        }
    }
    
    deinit {
        stopMonitoring()
    }
}