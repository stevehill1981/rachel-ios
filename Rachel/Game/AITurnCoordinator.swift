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
        
        // Prevent duplicate timers
        if turnTimer?.isValid == true {
            print("WARNING: AI turn timer already active, skipping duplicate")
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
            print("AI Turn skipped - game not in playing state or invalid player index")
            return
        }
        
        let currentPlayer = engine.state.players[engine.state.currentPlayerIndex]
        guard currentPlayer.isAI else { 
            print("AI Turn skipped - current player is not AI")
            return 
        }
        
        print("AI Turn: \(currentPlayer.name) (Player \(engine.state.currentPlayerIndex))")
        print("Hand size: \(currentPlayer.hand.count)")
        if let topCard = engine.state.discardPile.last {
            print("Top card: \(topCard)")
        }
        print("Pending pickups: \(engine.state.pendingPickups)")
        print("Nominated suit: \(engine.state.nominatedSuit?.rawValue ?? "none")")
        
        let aiPlayer = AIPlayer(skillLevel: currentPlayer.aiSkillLevel ?? .medium)
        let decision = aiPlayer.decideMove(for: currentPlayer, gameState: engine.state)
        
        print("AI Decision: \(decision)")
        
        // Add a small delay before executing the move for visual effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.executeDecision(decision)
        }
    }
    
    private func executeDecision(_ decision: AIDecision) {
        guard engine != nil else { 
            print("ERROR: No engine available for AI decision")
            aiThinkingPlayerIndex = nil
            aiSelectedCardIndex = nil
            return 
        }
        
        // Safety timeout - if decision doesn't execute within 3 seconds, clear indicators
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            if self?.aiThinkingPlayerIndex != nil {
                print("WARNING: AI decision timed out, clearing indicators")
                self?.aiThinkingPlayerIndex = nil
                self?.aiSelectedCardIndex = nil
                // Try to check for next turn
                self?.checkForAITurn()
            }
        }
        
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
        
        print("Executing AI decision...")
        
        switch decision {
        case .playCard(let index, let nominatedSuit):
            print("Attempting to play card at index \(index)")
            let played = engine.playCard(at: index, by: engine.state.currentPlayerIndex)
            if played {
                print("Successfully played card")
                if let suit = nominatedSuit, engine.state.needsSuitNomination {
                    print("Nominating suit: \(suit)")
                    engine.nominateSuit(suit)
                }
                engine.endTurn()
                print("Turn ended")
            } else {
                print("Failed to play card!")
            }
            
        case .playCards(let indices, let nominatedSuit):
            print("Attempting to play multiple cards: \(indices)")
            // Play multiple cards at once
            if engine.playMultipleCards(indices: indices, by: engine.state.currentPlayerIndex) {
                print("Successfully played cards")
                if let suit = nominatedSuit, engine.state.needsSuitNomination {
                    print("Nominating suit: \(suit)")
                    engine.nominateSuit(suit)
                }
                engine.endTurn()
                print("Turn ended")
            } else {
                print("Failed to play cards!")
            }
            
        case .drawCard:
            print("Drawing card")
            engine.drawCard()
            print("Card drawn, turn should auto-end")
            
        case .drawCards(let count):
            print("Drawing \(count) cards (pending pickups)")
            // drawCard already handles pending pickups
            engine.drawCard()
            print("Cards drawn, turn should auto-end")
        }
        
        // Clear the visual indicators
        aiThinkingPlayerIndex = nil
        aiSelectedCardIndex = nil
        
        print("Current player after decision: \(engine.state.currentPlayerIndex)")
        
        // Check if next player is also AI
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            print("Checking for next AI turn...")
            self?.checkForAITurn()
        }
    }
    
    deinit {
        stopMonitoring()
    }
}