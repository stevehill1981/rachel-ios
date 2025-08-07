//
//  PlayersColumnView.swift
//  Rachel
//
//  Created by Steve Hill on 07/08/2025.
//

import SwiftUI

struct PlayersColumnView: View {
    @ObservedObject var engine: GameEngine
    @ObservedObject var aiCoordinator: AITurnCoordinator
    
    var body: some View {
        VStack(spacing: 8) {
            // Players in vertical column with direction arrows
            GeometryReader { geometry in
                let players = playersInOrder()
                let playerCount = players.count
                let avatarSize: CGFloat = 40
                let availableHeight = geometry.size.height
                let spacing = (availableHeight - (CGFloat(playerCount) * avatarSize)) / CGFloat(max(1, playerCount + 1))
                
                ZStack(alignment: .top) {
                    // Draw arrows between players
                    ForEach(0..<max(0, playerCount - 1), id: \.self) { index in
                        VerticalArrowBetweenPlayers(
                            index: index,
                            spacing: spacing,
                            avatarSize: avatarSize,
                            direction: engine.state.direction
                        )
                    }
                    
                    // Draw players
                    ForEach(Array(players.enumerated()), id: \.element.0.id) { index, playerData in
                        let (player, actualIndex) = playerData
                        
                        CompactPlayerView(
                            player: player,
                            isCurrentPlayer: actualIndex == engine.state.currentPlayerIndex,
                            cardCount: player.hand.count,
                            isThinking: aiCoordinator.aiThinkingPlayerIndex == actualIndex,
                            playerIndex: actualIndex
                        )
                        .offset(y: CGFloat(index) * (avatarSize + spacing) + spacing)
                    }
                }
            }
        }
    }
    
    // Keep players in fixed positions
    private func playersInOrder() -> [(Player, Int)] {
        return engine.state.players.enumerated().map { ($0.element, $0.offset) }
    }
}

struct CompactPlayerView: View {
    let player: Player
    let isCurrentPlayer: Bool
    let cardCount: Int
    let isThinking: Bool
    let playerIndex: Int
    
    private let avatarSize: CGFloat = 40
    
    var body: some View {
        HStack(spacing: 8) {
            // Avatar with card count badge
            ZStack {
                // Avatar circle
                Circle()
                    .fill(avatarColor)
                    .frame(width: avatarSize, height: avatarSize)
                
                // Current player ring
                if isCurrentPlayer {
                    Circle()
                        .strokeBorder(Color.yellow, lineWidth: 2)
                        .frame(width: avatarSize + 4, height: avatarSize + 4)
                }
                
                // Player initial
                Text(String(player.name.prefix(1)))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                // Thinking indicator
                if isThinking {
                    ProgressView()
                        .scaleEffect(0.6)
                        .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                        .frame(width: avatarSize, height: avatarSize)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                
                // Card count badge
                ZStack {
                    Circle()
                        .fill(cardCount == 1 ? Color.red : Color.black)
                        .frame(width: 18, height: 18)
                    
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 1.5)
                        .frame(width: 18, height: 18)
                    
                    Text("\(cardCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(x: avatarSize * 0.35, y: -avatarSize * 0.35)
            }
            
            // Player name
            VStack(alignment: .leading, spacing: 0) {
                Text(player.name)
                    .font(.system(size: 12, weight: isCurrentPlayer ? .semibold : .medium))
                    .foregroundColor(isCurrentPlayer ? .yellow : .white)
                    .lineLimit(1)
                
                if player.isAI, let skillLevel = player.aiSkillLevel {
                    Text(skillLevel.name)
                        .font(.system(size: 9))
                        .foregroundColor(skillLevelColor(skillLevel))
                }
            }
            
            Spacer()
        }
        .frame(width: 120)
        .scaleEffect(isCurrentPlayer ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isCurrentPlayer)
    }
    
    private var avatarColor: Color {
        if playerIndex == 0 {
            return .blue
        } else if isCurrentPlayer {
            return .orange
        } else {
            switch player.aiSkillLevel {
            case .easy:
                return .green.opacity(0.8)
            case .medium:
                return .orange.opacity(0.8)
            case .hard:
                return .red.opacity(0.8)
            case .none:
                return .gray
            }
        }
    }
    
    private func skillLevelColor(_ level: AISkillLevel) -> Color {
        switch level {
        case .easy:
            return .green.opacity(0.8)
        case .medium:
            return .orange.opacity(0.8)
        case .hard:
            return .red.opacity(0.8)
        }
    }
}

struct VerticalArrowBetweenPlayers: View {
    let index: Int
    let spacing: CGFloat
    let avatarSize: CGFloat
    let direction: Direction
    
    var body: some View {
        let xPosition = (avatarSize + spacing) / 2 - (spacing / 4)
        let yPosition = CGFloat(index + 1) * (avatarSize + spacing) + spacing - (spacing / 2)
        
        ZStack {
            // Shadow circle
            Circle()
                .fill(Color.black.opacity(0.3))
                .frame(width: 16, height: 16)
                .offset(x: 1, y: 1)
            
            // Background circle with outline
            Circle()
                .fill(Color.black.opacity(0.8))
                .frame(width: 16, height: 16)
                .overlay(
                    Circle()
                        .strokeBorder(Color.yellow.opacity(0.6), lineWidth: 1)
                )
            
            // Arrow icon (down for clockwise, up for counter-clockwise)
            Image(systemName: direction == .clockwise ? "chevron.down" : "chevron.up")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.yellow)
        }
        .position(x: xPosition, y: yPosition) // Center on avatar circle
        .zIndex(100 + Double(index))
    }
}

#Preview {
    ZStack {
        BaizeBackground()
        
        HStack {
            let players = [
                Player(id: "1", name: "You"),
                Player(id: "2", name: "Alex", isAI: true, aiSkillLevel: .easy),
                Player(id: "3", name: "Sam", isAI: true, aiSkillLevel: .medium),
                Player(id: "4", name: "Jamie", isAI: true, aiSkillLevel: .hard)
            ]
            
            let engine = GameEngine(players: players)
            let aiCoordinator = AITurnCoordinator(engine: engine)
            
            PlayersColumnView(engine: engine, aiCoordinator: aiCoordinator)
                .frame(width: 140)
                .padding()
                .onAppear {
                    engine.dealCards()
                    engine.updateState { state in
                        state.currentPlayerIndex = 2
                    }
                }
            
            Spacer()
        }
    }
}
