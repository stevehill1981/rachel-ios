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
    
    var body: some View {
        Group {
            if isGameActive {
                GameView(engine: gameEngine) {
                    // Exit game
                    isGameActive = false
                }
            } else if showCustomGame {
                // TODO: Show custom game setup
                Text("Custom Game Setup")
                    .onTapGesture {
                        showCustomGame = false
                    }
            } else {
                StartScreenView(
                    onQuickPlay: startQuickPlay,
                    onCustomGame: {
                        showCustomGame = true
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
}

#Preview {
    ContentView()
}
