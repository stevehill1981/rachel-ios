//
//  PlayersListView.swift
//  Rachel
//
//  Created by Steve Hill on 06/08/2025.
//

import SwiftUI

struct PlayersListView: View {
    @ObservedObject var engine: GameEngine
    @ObservedObject var aiCoordinator: AITurnCoordinator
    
    var body: some View {
        VStack(spacing: 0) {
            // Direction indicator at top
            HStack {
                DirectionIndicator(direction: engine.state.direction)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // Scrollable player list
            ScrollView {
                VStack(spacing: 6) {
                    ForEach(Array(engine.state.players.enumerated()), id: \.element.id) { index, player in
                        PlayerRowView(
                            player: player,
                            isCurrentPlayer: index == engine.state.currentPlayerIndex,
                            cardCount: player.hand.count,
                            isThinking: aiCoordinator.aiThinkingPlayerIndex == index,
                            playerIndex: index,
                            nextPlayerIndex: getNextPlayerIndex(after: index),
                            totalPlayers: engine.state.players.count
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func getNextPlayerIndex(after index: Int) -> Int {
        if engine.state.direction == .clockwise {
            return (index + 1) % engine.state.players.count
        } else {
            return (index - 1 + engine.state.players.count) % engine.state.players.count
        }
    }
}

struct PlayerRowView: View {
    let player: Player
    let isCurrentPlayer: Bool
    let cardCount: Int
    let isThinking: Bool
    let playerIndex: Int
    let nextPlayerIndex: Int
    let totalPlayers: Int
    
    var isHumanPlayer: Bool {
        playerIndex == 0
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Player info
            HStack(spacing: 12) {
                // Position indicator
                Text("\(playerIndex + 1)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(width: 20)
                
                // Avatar
                ZStack {
                    Circle()
                        .fill(avatarColor)
                        .frame(width: 40, height: 40)
                    
                    if isCurrentPlayer {
                        Circle()
                            .strokeBorder(Color.yellow, lineWidth: 2)
                            .frame(width: 44, height: 44)
                    }
                    
                    Text(String(player.name.prefix(1)))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Player details
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(player.name)
                            .font(.system(size: 14, weight: isHumanPlayer ? .semibold : .medium))
                            .foregroundColor(isCurrentPlayer ? .yellow : .white)
                        
                        if player.isAI, let skillLevel = player.aiSkillLevel {
                            Text("(\(skillLevel.name))")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        if isThinking {
                            ProgressView()
                                .scaleEffect(0.6)
                                .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                        }
                    }
                    
                    // Card count
                    HStack(spacing: 4) {
                        ForEach(0..<min(cardCount, 10), id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(cardCount == 1 ? Color.red : Color.white.opacity(0.3))
                                .frame(width: 3, height: 12)
                        }
                        
                        if cardCount > 10 {
                            Text("+\(cardCount - 10)")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
                
                Spacer()
                
                // Turn indicator and card count
                VStack(alignment: .trailing, spacing: 4) {
                    if isCurrentPlayer {
                        HStack(spacing: 4) {
                            Text("TURN")
                                .font(.system(size: 10, weight: .bold))
                            Image(systemName: "play.fill")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(.yellow)
                    }
                    
                    Text("\(cardCount) cards")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(cardCount == 1 ? .red : .white.opacity(0.7))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(backgroundGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(borderColor, lineWidth: isCurrentPlayer ? 2 : 1)
                    )
            )
            
            // Direction arrow
            if playerIndex != totalPlayers - 1 {
                Image(systemName: "arrow.down")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.horizontal, 8)
            }
        }
    }
    
    private var backgroundGradient: LinearGradient {
        if isCurrentPlayer {
            return LinearGradient(
                colors: [Color.yellow.opacity(0.2), Color.yellow.opacity(0.1)],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else if isHumanPlayer {
            return LinearGradient(
                colors: [Color.blue.opacity(0.2), Color.blue.opacity(0.1)],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                colors: [Color.white.opacity(0.08), Color.white.opacity(0.04)],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    private var borderColor: Color {
        if isCurrentPlayer {
            return .yellow.opacity(0.8)
        } else if cardCount == 1 {
            return .red.opacity(0.5)
        } else {
            return .white.opacity(0.15)
        }
    }
    
    private var avatarColor: Color {
        if isHumanPlayer {
            return .blue
        } else {
            switch player.aiSkillLevel {
            case .easy:
                return .green
            case .medium:
                return .orange
            case .hard:
                return .red
            case .none:
                return .gray
            }
        }
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
            
            PlayersListView(engine: engine, aiCoordinator: aiCoordinator)
                .frame(maxHeight: 250)
                .onAppear {
                    engine.dealCards()
                    engine.updateState { state in
                        state.currentPlayerIndex = 3
                        state.direction = .counterclockwise
                    }
                }
            
            Spacer()
        }
    }
}