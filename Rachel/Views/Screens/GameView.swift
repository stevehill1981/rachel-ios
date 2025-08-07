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
                    // Players in horizontal row with overlap
                    PlayersRowView(engine: engine, aiCoordinator: aiCoordinator)
                        .frame(height: 120)
                    
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
        .onChange(of: engine.state.currentPlayerIndex) { _, _ in
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
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var turnNumber: Int {
        // Use the actual turn count from game state
        engine.state.turnCount + 1 // +1 because we want to show "Turn 1" not "Turn 0"
    }
    
    var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    var body: some View {
        ZStack {
            // Background that extends to top edge
            if !isLandscape {
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
            } else {
                // Simpler background for landscape with rounded bottom corners
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 12,
                    bottomTrailingRadius: 12,
                    topTrailingRadius: 0
                )
                .fill(Color.black)
                .overlay(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 12,
                        bottomTrailingRadius: 12,
                        topTrailingRadius: 0
                    )
                    .strokeBorder(Color.gray.opacity(0.1), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            
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
                .padding(.leading, isLandscape ? 40 : 20)
                
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
                    .padding(.trailing, isLandscape ? 40 : 20)
                }
            }
            .padding(.vertical, isLandscape ? 8 : 12)
            .padding(.top, isLandscape ? 0 : 8) // No extra padding in landscape
        }
        .frame(height: isLandscape ? 40 : 54) // Shorter in landscape
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
