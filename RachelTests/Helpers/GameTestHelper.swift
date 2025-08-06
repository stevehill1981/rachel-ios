//
//  GameTestHelper.swift
//  RachelTests
//
//  Created by Steve Hill on 05/08/2025.
//

import XCTest
@testable import Rachel

/// Helper methods for game testing to reduce code duplication
enum GameTestHelper {
    
    /// Executes a single turn for any player (human or AI)
    /// - Parameters:
    ///   - engine: The game engine
    ///   - printDebug: Whether to print debug information
    /// - Returns: A tuple indicating (played: Bool, drew: Bool)
    @discardableResult
    static func executeTurn(for engine: inout GameEngine, printDebug: Bool = false) -> (played: Bool, drew: Bool) {
        let currentPlayerIndex = engine.state.currentPlayerIndex
        let currentPlayer = engine.state.players[currentPlayerIndex]
        
        if printDebug {
            print("Player \(currentPlayerIndex) (\(currentPlayer.name)) has \(currentPlayer.hand.count) cards")
            if let topCard = engine.state.discardPile.last {
                print("Top card: \(topCard)")
            }
        }
        
        if currentPlayer.isAI {
            return executeAITurn(for: &engine, player: currentPlayer, playerIndex: currentPlayerIndex, printDebug: printDebug)
        } else {
            return executeHumanTurn(for: &engine, player: currentPlayer, playerIndex: currentPlayerIndex, printDebug: printDebug)
        }
    }
    
    /// Executes a turn for an AI player
    private static func executeAITurn(for engine: inout GameEngine, player: Player, playerIndex: Int, printDebug: Bool) -> (played: Bool, drew: Bool) {
        let aiPlayer = AIPlayer(skillLevel: player.aiSkillLevel ?? .medium)
        let decision = aiPlayer.decideMove(for: player, gameState: engine.state)
        
        if printDebug {
            print("AI decision: \(decision)")
        }
        
        switch decision {
        case .playCard(let index, let nominateSuit):
            let played = engine.playCard(at: index, by: playerIndex)
            if played {
                if let suit = nominateSuit, engine.state.needsSuitNomination {
                    engine.nominateSuit(suit)
                }
                engine.endTurn()
                return (played: true, drew: false)
            } else {
                // Failed to play, must draw
                engine.drawCard()
                return (played: false, drew: true)
            }
            
        case .playCards(let indices, let nominateSuit):
            // Play multiple cards at once
            if engine.playMultipleCards(indices: indices, by: playerIndex) {
                if let suit = nominateSuit, engine.state.needsSuitNomination {
                    engine.nominateSuit(suit)
                }
                engine.endTurn()
                return (played: true, drew: false)
            } else {
                // Failed to play any cards, must draw
                engine.drawCard()
                return (played: false, drew: true)
            }
            
        case .drawCard, .drawCards:
            engine.drawCard()
            return (played: false, drew: true)
        }
    }
    
    /// Executes a turn for a human player (tries to play first valid card)
    private static func executeHumanTurn(for engine: inout GameEngine, player: Player, playerIndex: Int, printDebug: Bool) -> (played: Bool, drew: Bool) {
        // Try to play valid cards
        if let topCard = engine.state.discardPile.last {
            for (index, card) in player.hand.cards.enumerated() {
                if GameRules.canPlay(card: card, on: topCard, gameState: engine.state) {
                    let played = engine.playCard(at: index, by: playerIndex)
                    if played {
                        if printDebug {
                            print("Human played card at index \(index)")
                        }
                        if card.rank == .ace && engine.state.needsSuitNomination {
                            engine.nominateSuit(.hearts) // Default nomination
                        }
                        engine.endTurn()
                        return (played: true, drew: false)
                    }
                    break
                }
            }
        }
        
        // No valid cards, must draw
        if printDebug {
            print("Human drew a card")
        }
        engine.drawCard()
        return (played: false, drew: true)
    }
    
    /// Runs a game for a specified number of turns or until completion
    /// - Parameters:
    ///   - engine: The game engine
    ///   - maxTurns: Maximum number of turns to run
    ///   - printDebug: Whether to print debug information
    /// - Returns: Game statistics
    static func runGame(engine: inout GameEngine, maxTurns: Int, printDebug: Bool = false) -> GameStats {
        var stats = GameStats()
        
        while stats.turnCount < maxTurns && engine.state.gameStatus == .playing {
            stats.turnCount += 1
            
            if printDebug {
                print("\n--- Turn \(stats.turnCount) ---")
            }
            
            let result = executeTurn(for: &engine, printDebug: printDebug)
            
            if result.played {
                stats.playCount += 1
                stats.consecutiveDraws = 0
            } else if result.drew {
                stats.drawCount += 1
                stats.consecutiveDraws += 1
                stats.maxConsecutiveDraws = max(stats.maxConsecutiveDraws, stats.consecutiveDraws)
            }
            
            if engine.state.gameStatus != .playing {
                stats.gameCompleted = true
                break
            }
        }
        
        return stats
    }
    
    /// Statistics collected during game execution
    struct GameStats {
        var turnCount = 0
        var playCount = 0
        var drawCount = 0
        var consecutiveDraws = 0
        var maxConsecutiveDraws = 0
        var gameCompleted = false
        
        var playRate: Double {
            turnCount > 0 ? Double(playCount) / Double(turnCount) : 0
        }
    }
}