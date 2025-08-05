//
//  PlayersView.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

import SwiftUI

struct PlayersView: View {
    @ObservedObject var engine: GameEngine
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Draw direction circle
                DirectionCircleView(
                    playerCount: engine.state.players.count,
                    direction: engine.state.direction,
                    size: geometry.size
                )
                
                // Place players in a circle/oval
                ForEach(Array(engine.state.players.enumerated()), id: \.element.id) { index, player in
                    PlayerIndicatorView(
                        player: player,
                        isCurrentPlayer: index == engine.state.currentPlayerIndex,
                        cardCount: player.hand.count
                    )
                    .position(
                        playerPosition(
                            index: index,
                            totalPlayers: engine.state.players.count,
                            in: geometry.size
                        )
                    )
                }
            }
        }
        .padding()
    }
    
    private func nextPlayerIndex(after index: Int) -> Int {
        if engine.state.direction == .clockwise {
            return (index + 1) % engine.state.players.count
        } else {
            return (index - 1 + engine.state.players.count) % engine.state.players.count
        }
    }
    
    private func playerPosition(index: Int, totalPlayers: Int, in size: CGSize) -> CGPoint {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        
        // Make the radius responsive to the container size
        let radiusX = size.width * 0.4  // 40% of width
        let radiusY = size.height * 0.35 // 35% of height for oval shape
        
        // Start from the bottom (6 o'clock position) so player 0 (human) is at bottom
        let startAngle = Double.pi / 2  // 90 degrees (bottom)
        
        // Calculate angle for this player
        let angleStep = (2 * Double.pi) / Double(totalPlayers)
        let angle = startAngle + (Double(index) * angleStep)
        
        // Calculate position
        let x = center.x + radiusX * Darwin.cos(angle)
        let y = center.y + radiusY * Darwin.sin(angle)
        
        return CGPoint(x: x, y: y)
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
    
    return ZStack {
        BaizeBackground()
        PlayersView(engine: engine)
    }
}

struct DirectionCircleView: View {
    let playerCount: Int
    let direction: Direction
    let size: CGSize
    
    var body: some View {
        ZStack {
            // Draw oval through player positions
            Ellipse()
                .stroke(
                    Color.white.opacity(0.2),
                    style: StrokeStyle(lineWidth: 1.5, dash: [8, 4])
                )
                .frame(
                    width: size.width * 0.8,  // 0.4 radius * 2
                    height: size.height * 0.7  // 0.35 radius * 2
                )
                .position(x: size.width / 2, y: size.height / 2 - 10)
            
            // Add arrowheads between each player
            ForEach(0..<playerCount, id: \.self) { index in
                ArrowheadView(
                    fromIndex: index,
                    toIndex: nextPlayerIndex(after: index),
                    playerCount: playerCount,
                    size: size
                )
            }
        }
    }
    
    private func nextPlayerIndex(after index: Int) -> Int {
        if direction == .clockwise {
            return (index + 1) % playerCount
        } else {
            return (index - 1 + playerCount) % playerCount
        }
    }
}

struct ArrowheadView: View {
    let fromIndex: Int
    let toIndex: Int
    let playerCount: Int
    let size: CGSize
    
    var body: some View {
        Image(systemName: "arrowtriangle.forward.fill")
            .font(.caption)
            .foregroundColor(.white.opacity(0.4))
            .rotationEffect(arrowAngle())
            .position(arrowPosition())
    }
    
    private func arrowPosition() -> CGPoint {
        let center = CGPoint(x: size.width / 2, y: size.height / 2 - 10) // Match oval offset
        let radiusX = size.width * 0.4
        let radiusY = size.height * 0.35
        
        // Position arrow between the two players
        let fromAngle = angleForPlayer(fromIndex)
        let toAngle = angleForPlayer(toIndex)
        
        // Calculate midpoint angle
        var midAngle: Double
        let angleDiff = toAngle - fromAngle
        
        if abs(angleDiff) > Double.pi {
            // Handle wrap-around
            if angleDiff > 0 {
                midAngle = fromAngle + (angleDiff - 2 * Double.pi) / 2
            } else {
                midAngle = fromAngle + (angleDiff + 2 * Double.pi) / 2
            }
        } else {
            midAngle = fromAngle + angleDiff / 2
        }
        
        // Position on the oval at the midpoint angle
        return CGPoint(
            x: center.x + radiusX * Darwin.cos(midAngle),
            y: center.y + radiusY * Darwin.sin(midAngle)
        )
    }
    
    private func arrowAngle() -> Angle {
        let fromAngle = angleForPlayer(fromIndex)
        let toAngle = angleForPlayer(toIndex)
        
        // Calculate midpoint angle (same as position calculation)
        var midAngle: Double
        let angleDiff = toAngle - fromAngle
        
        if abs(angleDiff) > Double.pi {
            // Handle wrap-around
            if angleDiff > 0 {
                midAngle = fromAngle + (angleDiff - 2 * Double.pi) / 2
            } else {
                midAngle = fromAngle + (angleDiff + 2 * Double.pi) / 2
            }
        } else {
            midAngle = fromAngle + angleDiff / 2
        }
        
        // Calculate the tangent angle at the midpoint
        var tangentAngle: Double
        if toIndex == (fromIndex + 1) % playerCount {
            // Clockwise
            tangentAngle = midAngle + Double.pi / 2
        } else {
            // Counterclockwise
            tangentAngle = midAngle - Double.pi / 2
        }
        
        return Angle(radians: tangentAngle)
    }
    
    private func angleForPlayer(_ index: Int) -> Double {
        let startAngle = Double.pi / 2
        let angleStep = (2 * Double.pi) / Double(playerCount)
        return startAngle + (Double(index) * angleStep)
    }
}