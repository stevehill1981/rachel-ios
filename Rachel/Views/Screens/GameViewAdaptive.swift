//
//  GameViewAdaptive.swift
//  Rachel
//
//  Created by Steve Hill on 07/08/2025.
//

import SwiftUI

struct GameViewAdaptive: View {
    @ObservedObject var engine: GameEngine
    @StateObject private var aiCoordinator: AITurnCoordinator
    let onExit: () -> Void
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    init(engine: GameEngine, onExit: @escaping () -> Void) {
        self.engine = engine
        self.onExit = onExit
        self._aiCoordinator = StateObject(wrappedValue: AITurnCoordinator(engine: engine))
    }
    
    var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        ZStack {
            // Background
            BaizeBackground()
            
            VStack(spacing: 0) {
                if isLandscape && !isIPad {
                    landscapeGameLayout
                } else {
                    portraitGameLayout
                }
            }
            
            // Top bar overlaid on top
            VStack {
                TopBarView(engine: engine, onExit: onExit)
                Spacer()
            }
        }
        .ignoresSafeArea()
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
            gameOverlays
        }
    }
    
    var portraitGameLayout: some View {
        VStack {
            // Players in horizontal row with overlap
            PlayersRowView(engine: engine, aiCoordinator: aiCoordinator)
                .frame(height: isIPad ? 140 : 120)
            
            // Game info below players
            GameInfoView(
                pendingPickups: engine.state.pendingPickups,
                skipNextPlayer: engine.state.pendingSkips > 0
            )
            
            Spacer()
            
            // Center play area
            HStack {
                Spacer()
                CenterCardAreaView(engine: engine)
                    .scaleEffect(isIPad ? 1.2 : 1.0)
                Spacer()
            }
            
            Spacer()
            
            // Player's hand
            PlayerHandView(engine: engine)
        }
        .padding()
    }
    
    var landscapeGameLayout: some View {
        HStack(spacing: 0) {
            // Left side - Players column
            PlayersColumnView(engine: engine, aiCoordinator: aiCoordinator)
                .frame(width: 140)
                .padding(.leading)
            
            // Right side - Game area
            VStack(spacing: 8) {
                // Game info at top
                GameInfoView(
                    pendingPickups: engine.state.pendingPickups,
                    skipNextPlayer: engine.state.pendingSkips > 0
                )
                .padding(.horizontal)
                
                // Center area with larger cards
                HStack {
                    Spacer()
                    CenterCardAreaView(engine: engine)
                        .scaleEffect(1.1) // Bigger cards in landscape
                    Spacer()
                }
                .frame(maxHeight: .infinity)
                
                // Player's hand at bottom
                PlayerHandView(engine: engine)
                    .padding(.horizontal)
            }
            .padding(.vertical, 8)
        }
    }
    
    private func getCurrentPlayer() -> Player? {
        guard engine.state.currentPlayerIndex < engine.state.players.count else { return nil }
        return engine.state.players[engine.state.currentPlayerIndex]
    }
    
    var gameOverlays: some View {
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

#Preview("Portrait") {
    let players = [
        Player(id: "1", name: "You"),
        Player(id: "2", name: "Alex", isAI: true, aiSkillLevel: .easy),
        Player(id: "3", name: "Sam", isAI: true, aiSkillLevel: .medium),
        Player(id: "4", name: "Jamie", isAI: true, aiSkillLevel: .hard)
    ]
    let engine = GameEngine(players: players)
    engine.dealCards()
    
    return GameViewAdaptive(engine: engine) {
        print("Exit game")
    }
}

#Preview("Landscape") {
    let players = [
        Player(id: "1", name: "You"),
        Player(id: "2", name: "Alex", isAI: true, aiSkillLevel: .easy),
        Player(id: "3", name: "Sam", isAI: true, aiSkillLevel: .medium),
        Player(id: "4", name: "Jamie", isAI: true, aiSkillLevel: .hard),
        Player(id: "5", name: "Casey", isAI: true, aiSkillLevel: .easy),
        Player(id: "6", name: "Jordan", isAI: true, aiSkillLevel: .medium)
    ]
    let engine = GameEngine(players: players)
    engine.dealCards()
    
    return GameViewAdaptive(engine: engine) {
        print("Exit game")
    }
}