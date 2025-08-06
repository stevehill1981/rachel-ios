//
//  PlayersGridView.swift
//  Rachel
//
//  Created by Steve Hill on 06/08/2025.
//

import SwiftUI

struct PlayersGridView: View {
    @ObservedObject var engine: GameEngine
    @ObservedObject var aiCoordinator: AITurnCoordinator
    
    var columns: [GridItem] {
        let playerCount = engine.state.players.count
        
        // Layout strategy based on player count
        switch playerCount {
        case 2:
            // 2 players: side by side
            return Array(repeating: GridItem(.flexible()), count: 2)
        case 3...4:
            // 3-4 players: 2x2 grid
            return Array(repeating: GridItem(.flexible()), count: 2)
        case 5...6:
            // 5-6 players: 3 columns
            return Array(repeating: GridItem(.flexible()), count: 3)
        case 7...8:
            // 7-8 players: 4 columns
            return Array(repeating: GridItem(.flexible()), count: 4)
        default:
            return Array(repeating: GridItem(.flexible()), count: 3)
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Direction indicator
            DirectionIndicator(direction: engine.state.direction)
                .padding(.bottom, 4)
            
            // Players grid
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Array(engine.state.players.enumerated()), id: \.element.id) { index, player in
                    PlayerCompactView(
                        player: player,
                        isCurrentPlayer: index == engine.state.currentPlayerIndex,
                        cardCount: player.hand.count,
                        isThinking: aiCoordinator.aiThinkingPlayerIndex == index,
                        playerIndex: index,
                        totalPlayers: engine.state.players.count
                    )
                }
            }
        }
        .padding(.horizontal, 12)
    }
}

struct PlayerCompactView: View {
    let player: Player
    let isCurrentPlayer: Bool
    let cardCount: Int
    let isThinking: Bool
    let playerIndex: Int
    let totalPlayers: Int
    
    var isHumanPlayer: Bool {
        playerIndex == 0 // First player is always human
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // Player avatar with card count
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundGradient)
                    .frame(height: 56)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(borderColor, lineWidth: isCurrentPlayer ? 2 : 1)
                    )
                
                HStack(spacing: 8) {
                    // Avatar circle
                    ZStack {
                        Circle()
                            .fill(avatarColor)
                            .frame(width: 36, height: 36)
                        
                        Text(String(player.name.prefix(1)))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    // Name and status
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text(player.name)
                                .font(.system(size: 13, weight: isHumanPlayer ? .semibold : .medium))
                                .foregroundColor(isCurrentPlayer ? .yellow : .white)
                                .lineLimit(1)
                            
                            if isThinking {
                                ProgressView()
                                    .scaleEffect(0.5)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                            }
                        }
                        
                        // AI difficulty or card count
                        HStack(spacing: 4) {
                            if player.isAI, let skillLevel = player.aiSkillLevel {
                                Text(skillLevel.name)
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            // Card count
                            HStack(spacing: 2) {
                                Image(systemName: "rectangle.portrait.fill")
                                    .font(.system(size: 10))
                                Text("\(cardCount)")
                                    .font(.system(size: 11, weight: .bold))
                            }
                            .foregroundColor(cardCount == 1 ? .red : .white.opacity(0.8))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Turn indicator
                    if isCurrentPlayer {
                        Image(systemName: "play.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                            .padding(.trailing, 4)
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .scaleEffect(isCurrentPlayer ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isCurrentPlayer)
    }
    
    private var backgroundGradient: LinearGradient {
        if isCurrentPlayer {
            return LinearGradient(
                colors: [Color.yellow.opacity(0.3), Color.yellow.opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if isHumanPlayer {
            return LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var borderColor: Color {
        if isCurrentPlayer {
            return .yellow
        } else if cardCount == 1 {
            return .red.opacity(0.6)
        } else {
            return .white.opacity(0.2)
        }
    }
    
    private var avatarColor: Color {
        if isHumanPlayer {
            return .blue
        } else if isCurrentPlayer {
            return .orange
        } else {
            return .gray
        }
    }
}

struct DirectionIndicator: View {
    let direction: Direction
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: direction == .clockwise ? "arrow.clockwise" : "arrow.counterclockwise")
                .font(.system(size: 14))
            Text(direction == .clockwise ? "Clockwise" : "Counter-clockwise")
                .font(.system(size: 12))
        }
        .foregroundColor(.white.opacity(0.6))
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.1))
        )
    }
}

#Preview {
    ZStack {
        BaizeBackground()
        
        VStack {
            // Preview with 8 players
            let players8 = [
                Player(id: "1", name: "You"),
                Player(id: "2", name: "Alex", isAI: true, aiSkillLevel: .easy),
                Player(id: "3", name: "Sam", isAI: true, aiSkillLevel: .medium),
                Player(id: "4", name: "Jamie", isAI: true, aiSkillLevel: .hard),
                Player(id: "5", name: "Casey", isAI: true, aiSkillLevel: .easy),
                Player(id: "6", name: "Jordan", isAI: true, aiSkillLevel: .medium),
                Player(id: "7", name: "Morgan", isAI: true, aiSkillLevel: .hard),
                Player(id: "8", name: "Riley", isAI: true, aiSkillLevel: .easy)
            ]
            
            let engine = GameEngine(players: players8)
            let aiCoordinator = AITurnCoordinator(engine: engine)
            
            PlayersGridView(engine: engine, aiCoordinator: aiCoordinator)
                .onAppear {
                    engine.dealCards()
                    engine.updateState { state in
                        state.currentPlayerIndex = 3 // Show someone as current player
                    }
                }
            
            Spacer()
        }
        .padding()
    }
}