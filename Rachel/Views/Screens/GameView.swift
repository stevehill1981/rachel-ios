//
//  GameView.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var engine: GameEngine
    let onExit: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            BaizeBackground()
            
            VStack {
                // Top bar with exit button
                TopBarView(onExit: onExit)
                
                // Game table area
                VStack {
                    // Opponent area
                    OpponentAreaView(engine: engine)
                        .frame(maxHeight: 200)
                    
                    // Center play area
                    CenterPlayAreaView(engine: engine)
                        .frame(height: 200)
                    
                    // Player's hand
                    PlayerHandView(engine: engine)
                        .frame(maxHeight: 250)
                }
                .padding()
            }
        }
    }
}

struct TopBarView: View {
    let onExit: () -> Void
    
    var body: some View {
        HStack {
            Button("Exit") {
                onExit()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.red.opacity(0.8))
            .cornerRadius(8)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    let players = [
        Player(id: "1", name: "You"),
        Player(id: "2", name: "Alex", isAI: true),
        Player(id: "3", name: "Sam", isAI: true),
        Player(id: "4", name: "Jamie", isAI: true)
    ]
    var engine = GameEngine(players: players)
    engine.dealCards()
    
    return GameView(engine: engine) {
        print("Exit game")
    }
}