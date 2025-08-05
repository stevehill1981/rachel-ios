//
//  ContentView.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var gameEngine: GameEngine?
    @State private var showCustomGame = false
    
    var body: some View {
        if let engine = gameEngine {
            // TODO: Show game view
            Text("Game is running!")
                .onTapGesture {
                    // Reset game
                    gameEngine = nil
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
    
    private func startQuickPlay() {
        // Create 4 players: human + 3 AI
        let playerName = DeviceHelper.getPlayerName()
        let players = [
            Player(id: "1", name: playerName),
            Player(id: "2", name: "Alex", isAI: true),
            Player(id: "3", name: "Sam", isAI: true),
            Player(id: "4", name: "Jamie", isAI: true)
        ]
        
        // Create and setup game
        var engine = GameEngine(players: players)
        engine.dealCards()
        
        gameEngine = engine
    }
}

#Preview {
    ContentView()
}
