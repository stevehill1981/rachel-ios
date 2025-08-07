//
//  PlayersRowView.swift
//  Rachel
//
//  Created by Steve Hill on 06/08/2025.
//

import SwiftUI

struct PlayersRowView: View {
    @ObservedObject var engine: GameEngine
    @ObservedObject var aiCoordinator: AITurnCoordinator
    
    var body: some View {
        VStack(spacing: 12) {
            // Players in overlapping row with direction arrows
            GeometryReader { geometry in
                let players = playersInVisualOrder()
                let playerCount = players.count
                let avatarWidth: CGFloat = 50
                let overlap: CGFloat = 25
                
                // Calculate total space needed with overlaps
                let minWidth = avatarWidth + CGFloat(playerCount - 1) * (avatarWidth - overlap)
                let availableWidth = geometry.size.width
                
                // If we have more space than needed, spread them out more
                let actualSpacing = minWidth < availableWidth ? 
                    (availableWidth - avatarWidth) / CGFloat(max(1, playerCount - 1)) :
                    avatarWidth - overlap
                
                ZStack(alignment: .leading) {
                    // Draw arrows between players
                    ForEach(0..<max(0, playerCount - 1), id: \.self) { index in
                        ArrowBetweenPlayers(
                            index: index,
                            actualSpacing: actualSpacing,
                            avatarWidth: avatarWidth,
                            direction: engine.state.direction
                        )
                    }
                    
                    // Draw players
                    ForEach(Array(players.enumerated()), id: \.element.0.id) { index, playerData in
                        let (player, actualIndex) = playerData
                        
                        PlayerAvatarView(
                            player: player,
                            isCurrentPlayer: actualIndex == engine.state.currentPlayerIndex,
                            cardCount: player.hand.count,
                            isThinking: aiCoordinator.aiThinkingPlayerIndex == actualIndex,
                            playerIndex: actualIndex
                        )
                        .offset(x: CGFloat(index) * actualSpacing)
                        .zIndex(zIndexForPlayer(at: index))
                    }
                }
                .frame(height: 90)
            }
            .frame(height: 90)
        }
    }
    
    // Arrange players based on direction for better visual flow
    private func playersInVisualOrder() -> [(Player, Int)] {
        let players = engine.state.players.enumerated().map { ($0.element, $0.offset) }
        
        // Always show human player (index 0) first, then others in play order
        var ordered: [(Player, Int)] = []
        
        // Add human player first
        if let humanPlayer = players.first(where: { $0.1 == 0 }) {
            ordered.append(humanPlayer)
        }
        
        // Add other players in play direction order starting from player 1
        if engine.state.direction == .clockwise {
            for i in 1..<players.count {
                if let player = players.first(where: { $0.1 == i }) {
                    ordered.append(player)
                }
            }
        } else {
            // Counter-clockwise: reverse the order of AI players
            for i in stride(from: players.count - 1, through: 1, by: -1) {
                if let player = players.first(where: { $0.1 == i }) {
                    ordered.append(player)
                }
            }
        }
        
        return ordered
    }
    
    // Z-index based on direction - players "later" in play order appear on top
    private func zIndexForPlayer(at visualIndex: Int) -> Double {
        if engine.state.direction == .clockwise {
            return Double(visualIndex)
        } else {
            return Double(engine.state.players.count - visualIndex)
        }
    }
}

struct PlayerAvatarView: View {
    let player: Player
    let isCurrentPlayer: Bool
    let cardCount: Int
    let isThinking: Bool
    let playerIndex: Int
    
    private let avatarSize: CGFloat = 50
    
    var body: some View {
        VStack(spacing: 0) {
            // Avatar with card count badge (fixed height)
            ZStack {
                // Shadow for depth
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: avatarSize + 4, height: avatarSize + 4)
                    .offset(x: 2, y: 2)
                
                // Avatar circle
                Circle()
                    .fill(avatarColor)
                    .frame(width: avatarSize, height: avatarSize)
                
                // Current player ring
                if isCurrentPlayer {
                    Circle()
                        .strokeBorder(Color.yellow, lineWidth: 3)
                        .frame(width: avatarSize + 6, height: avatarSize + 6)
                }
                
                // Player initial
                Text(String(player.name.prefix(1)))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                // Thinking indicator
                if isThinking {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                        .frame(width: avatarSize, height: avatarSize)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                
                // Card count badge
                ZStack {
                    Circle()
                        .fill(cardCount == 1 ? Color.red : Color.black)
                        .frame(width: 24, height: 24)
                    
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    Text("\(cardCount)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(x: avatarSize * 0.35, y: -avatarSize * 0.35)
            }
            .frame(height: avatarSize + 10) // Fixed height for all avatars
            
            // Player name below (separate from avatar alignment)
            VStack(spacing: 0) {
                Text(player.name)
                    .font(.system(size: 11, weight: isCurrentPlayer ? .semibold : .medium))
                    .foregroundColor(isCurrentPlayer ? .yellow : .white)
                    .lineLimit(1)
                
                if player.isAI, let skillLevel = player.aiSkillLevel {
                    Text(skillLevel.name)
                        .font(.system(size: 9))
                        .foregroundColor(skillLevelColor(skillLevel))
                }
            }
            .frame(height: 30) // Fixed height for labels
        }
        .scaleEffect(isCurrentPlayer ? 1.1 : 1.0)
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

struct ArrowBetweenPlayers: View {
    let index: Int
    let actualSpacing: CGFloat
    let avatarWidth: CGFloat
    let direction: Direction
    
    var body: some View {
        let currentPlayerX = CGFloat(index) * actualSpacing
        let nextPlayerX = CGFloat(index + 1) * actualSpacing
        
        // Position arrow in the visible gap between overlapping players
        let gapCenterX: CGFloat = {
            if actualSpacing < avatarWidth {
                // Players overlap - put arrow in the visible gap
                return currentPlayerX + avatarWidth - (avatarWidth - actualSpacing) / 2
            } else {
                // Players don't overlap - center between them
                return (currentPlayerX + nextPlayerX + avatarWidth) / 2
            }
        }()
        
        ZStack {
            // Shadow circle
            Circle()
                .fill(Color.black.opacity(0.3))
                .frame(width: 20, height: 20)
                .offset(x: 1, y: 1)
            
            // Background circle with outline
            Circle()
                .fill(Color.black.opacity(0.8))
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .strokeBorder(Color.yellow.opacity(0.6), lineWidth: 1.5)
                )
            
            // Arrow icon
            Image(systemName: direction == .clockwise ? "chevron.right" : "chevron.left")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.yellow)
        }
        .position(x: gapCenterX, y: avatarWidth/2 + 5) // Center of avatar circle
        .zIndex(100 + Double(index)) // Always above all players
    }
}

#Preview("4 Players Clockwise") {
    ZStack {
        BaizeBackground()
        
        VStack {
            let players = [
                Player(id: "1", name: "You"),
                Player(id: "2", name: "Alex", isAI: true, aiSkillLevel: .easy),
                Player(id: "3", name: "Sam", isAI: true, aiSkillLevel: .medium),
                Player(id: "4", name: "Jamie", isAI: true, aiSkillLevel: .hard)
            ]
            
            let engine = GameEngine(players: players)
            let aiCoordinator = AITurnCoordinator(engine: engine)
            
            PlayersRowView(engine: engine, aiCoordinator: aiCoordinator)
                .onAppear {
                    engine.dealCards()
                    engine.updateState { state in
                        state.currentPlayerIndex = 2
                    }
                }
            
            Spacer()
        }
        .padding()
    }
}

#Preview("8 Players Counter-clockwise") {
    ZStack {
        BaizeBackground()
        
        VStack {
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
            
            PlayersRowView(engine: engine, aiCoordinator: aiCoordinator)
                .onAppear {
                    engine.dealCards()
                    engine.updateState { state in
                        state.currentPlayerIndex = 3
                        state.direction = .counterclockwise
                        // Give last player only 1 card
                        state.players[7].hand.removeAllCards()
                        state.players[7].hand.addCard(Card(rank: .ace, suit: .hearts))
                    }
                }
            
            Spacer()
        }
        .padding()
    }
}