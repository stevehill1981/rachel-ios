//
//  GameView.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var engine: GameEngine
    @StateObject private var aiCoordinator: AITurnCoordinator
    let onExit: () -> Void
    
    init(engine: GameEngine, onExit: @escaping () -> Void) {
        self.engine = engine
        self.onExit = onExit
        self._aiCoordinator = StateObject(wrappedValue: AITurnCoordinator(engine: engine))
    }
    
    var body: some View {
        ZStack {
            // Background
            BaizeBackground()
            
            VStack(spacing: 0) {
                // Top bar with exit button
                TopBarView(engine: engine, onExit: onExit)
                
                // Game table area
                VStack {
                    // All players
                    PlayersView(engine: engine, aiCoordinator: aiCoordinator)
                        .frame(maxHeight: 170)
                    
                    // Game info below players
                    GameInfoView(
                        pendingPickups: engine.state.pendingPickups,
                        skipNextPlayer: engine.state.pendingSkips > 0
                    )
                    
                    Spacer()
                    
                    // Center play area (draw and discard only)
                    HStack {
                        Spacer()
                        CenterCardAreaView(engine: engine)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // Player's hand
                    PlayerHandView(engine: engine)
                }
                .padding()
            }
        }
        .ignoresSafeArea(.container, edges: .top) // Let background extend under status bar
        .onAppear {
            aiCoordinator.startMonitoring()
        }
        .onDisappear {
            aiCoordinator.stopMonitoring()
        }
        .onChange(of: engine.state.currentPlayerIndex) {
            aiCoordinator.checkForAITurn()
        }
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
        .overlay {
            ZStack {
                if engine.state.gameStatus == .finished {
                    GameEndView(
                        finishedPlayers: engine.state.finishedPlayerIndices.compactMap { index in
                            engine.state.players.indices.contains(index) ? engine.state.players[index] : nil
                        },
                        allPlayers: engine.state.players,
                        onPlayAgain: {
                            // Reset the game
                            engine.resetGame()
                            engine.dealCards()
                            aiCoordinator.checkForAITurn()
                        },
                        onExit: onExit
                    )
                }
                
                if engine.state.needsSuitNomination && engine.state.currentPlayerIndex == 0 {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                    
                    SuitNominationView { suit in
                        engine.nominateSuit(suit)
                        engine.endTurn()
                    }
                }
            }
        }
    }
}

struct TopBarView: View {
    @ObservedObject var engine: GameEngine
    let onExit: () -> Void
    
    var turnNumber: Int {
        // Calculate turn number based on how many cards have been played
        engine.state.discardPile.count
    }
    
    var body: some View {
        ZStack {
            // Background that extends to top edge
            VStack(spacing: 0) {
                Color.black
                    .frame(height: 50) // Extra height to cover safe area
                Rectangle()
                    .fill(Color.black)
                    .overlay(
                        Rectangle()
                            .strokeBorder(Color.gray.opacity(0.1), lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .ignoresSafeArea(edges: .top)
            
            // Content
            HStack(spacing: 0) {
                // Turn counter
                HStack(spacing: 6) {
                    Image(systemName: "arrow.trianglehead.clockwise")
                        .font(.caption)
                    Text("Turn \(turnNumber)")
                        .font(.footnote)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.leading, 20)
                
                Spacer()
                
                // Exit button
                Button(action: onExit) {
                    HStack(spacing: 6) {
                        Text("Exit")
                            .font(.footnote)
                            .fontWeight(.semibold)
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding(.trailing, 20)
                }
            }
            .padding(.vertical, 12)
            .padding(.top, 8) // Position content below safe area
        }
        .frame(height: 54) // Taller to fully cover Dynamic Island
    }
}

#Preview {
    let players = [
        Player(id: "1", name: "You"),
        Player(id: "2", name: "Alex (Easy)", isAI: true, aiSkillLevel: .easy),
        Player(id: "3", name: "Sam (Medium)", isAI: true, aiSkillLevel: .medium),
        Player(id: "4", name: "Jamie (Hard)", isAI: true, aiSkillLevel: .hard)
    ]
    let engine = GameEngine(players: players)
    engine.dealCards()
    
    return GameView(engine: engine) {
        print("Exit game")
    }
}
