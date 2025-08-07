//
//  ContentView.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameEngine = GameEngine(players: [])
    @State private var isGameActive = false
    @State private var showCustomGame = false
    @State private var showMultiplayer = false
    
    var body: some View {
        Group {
            if isGameActive {
                GameViewAdaptive(engine: gameEngine) {
                    // Exit game
                    isGameActive = false
                }
            } else if showCustomGame {
                CustomGameViewAdaptive(
                    isPresented: $showCustomGame,
                    onStartGame: { players in
                        startCustomGame(with: players)
                    }
                )
            } else if showMultiplayer {
                MultiplayerLobbyView(
                    isPresented: $showMultiplayer,
                    onStartGame: { players in
                        startCustomGame(with: players)
                    }
                )
            } else {
                StartScreenAdaptive(
                    onQuickPlay: startQuickPlay,
                    onCustomGame: {
                        showCustomGame = true
                    },
                    onMultiplayer: {
                        showMultiplayer = true
                    }
                )
            }
        }
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
    }
    
    private func startQuickPlay() {
        // Create 4 players: human + 3 AI
        let playerName = DeviceHelper.getPlayerName()
        let players = [
            Player(id: "1", name: playerName),
            Player(id: "2", name: "Alex", isAI: true),
            Player(id: "3", name: "Sam", isAI: true),
            Player(id: "4", name: "Jamie", isAI: true)
        ]
        
        // Setup game with new players
        gameEngine.setupNewGame(players: players)
        gameEngine.dealCards()
        
        isGameActive = true
    }
    
    private func startCustomGame(with players: [Player]) {
        // Setup game with custom players
        gameEngine.setupNewGame(players: players)
        gameEngine.dealCards()
        
        // Close custom game view and start the game
        showCustomGame = false
        isGameActive = true
    }
}

#Preview {
    ContentView()
}
