//
//  GameEndView.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

import SwiftUI

struct GameEndView: View {
    let finishedPlayers: [Player]
    let allPlayers: [Player]
    let onPlayAgain: () -> Void
    let onExit: () -> Void
    
    var winner: Player? {
        finishedPlayers.first
    }
    
    var loser: Player? {
        // The player who didn't finish (still has cards)
        allPlayers.first { player in
            !finishedPlayers.contains { $0.id == player.id }
        }
    }
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Title
                Text("Game Over!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Winner announcement
                if let winner = winner {
                    VStack(spacing: 8) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)
                        
                        Text("\(winner.name) Wins!")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.yellow)
                    }
                    .padding()
                }
                
                // Rankings
                VStack(alignment: .leading, spacing: 12) {
                    Text("Final Rankings")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    ForEach(Array(finishedPlayers.enumerated()), id: \.element.id) { index, player in
                        HStack {
                            Text("\(index + 1).")
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundColor(rankColor(for: index))
                                .frame(width: 30)
                            
                            Text(player.name)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            if index == 0 {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.yellow)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(rankBackgroundColor(for: index))
                        )
                    }
                    
                    // Show the loser (player who didn't finish)
                    if let loser = loser {
                        HStack {
                            Text("\(finishedPlayers.count + 1).")
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundColor(.red)
                                .frame(width: 30)
                            
                            Text(loser.name)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Spacer()
                            
                            Text("\(loser.hand.count) cards")
                                .font(.caption)
                                .foregroundColor(.red.opacity(0.8))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red.opacity(0.1))
                        )
                    }
                }
                .padding(.horizontal)
                
                // Buttons
                HStack(spacing: 20) {
                    Button(action: onExit) {
                        Label("Exit", systemImage: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.red.opacity(0.8))
                            )
                    }
                    
                    Button(action: onPlayAgain) {
                        Label("Play Again", systemImage: "arrow.clockwise")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.green)
                            )
                    }
                }
                .padding(.top, 10)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(white: 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
        }
        .transition(.scale.combined(with: .opacity))
    }
    
    private func rankColor(for index: Int) -> Color {
        switch index {
        case 0: return .yellow
        case 1: return .gray
        case 2: return .orange
        default: return .white.opacity(0.7)
        }
    }
    
    private func rankBackgroundColor(for index: Int) -> Color {
        switch index {
        case 0: return .yellow.opacity(0.1)
        case 1: return .gray.opacity(0.1)
        case 2: return .orange.opacity(0.1)
        default: return .white.opacity(0.05)
        }
    }
}

#Preview {
    let players = [
        Player(id: "1", name: "You"),
        Player(id: "2", name: "Alex", isAI: true),
        Player(id: "3", name: "Sam", isAI: true),
        Player(id: "4", name: "Jamie", isAI: true)
    ]
    
    GameEndView(
        finishedPlayers: [players[1], players[0], players[3]],
        allPlayers: players,
        onPlayAgain: { print("Play again") },
        onExit: { print("Exit") }
    )
}