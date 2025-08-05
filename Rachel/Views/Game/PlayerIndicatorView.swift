//
//  PlayerIndicatorView.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

import SwiftUI

struct PlayerIndicatorView: View {
    let player: Player
    let isCurrentPlayer: Bool
    let cardCount: Int
    
    var isHumanPlayer: Bool {
        !player.isAI
    }
    
    var body: some View {
        VStack(spacing: 6) {
            // Player avatar/icon with card count badge
            ZStack {
                Circle()
                    .fill(avatarColor)
                    .frame(width: 55, height: 55)
                
                if isCurrentPlayer {
                    Circle()
                        .strokeBorder(Color.yellow, lineWidth: 3)
                        .frame(width: 62, height: 62)
                }
                
                Text(String(player.name.prefix(1)))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Card count badge
                Text("\(cardCount)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 22, height: 22)
                    .background(
                        Circle()
                            .fill(cardCount == 1 ? Color.red : Color.black)
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.white, lineWidth: 1.5)
                            )
                    )
                    .offset(x: 20, y: -20)
            }
            
            // Player name
            Text(player.name)
                .font(.caption)
                .fontWeight(isHumanPlayer ? .semibold : .regular)
                .foregroundColor(.white)
        }
        .scaleEffect(isCurrentPlayer ? 1.15 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: isCurrentPlayer)
    }
    
    private var avatarColor: Color {
        if isHumanPlayer {
            return Color.blue
        } else if isCurrentPlayer {
            return Color.orange
        } else {
            return Color.gray
        }
    }
}

#Preview {
    ZStack {
        BaizeBackground()
        HStack(spacing: 20) {
            PlayerIndicatorView(
                player: Player(id: "1", name: "Alex"),
                isCurrentPlayer: false,
                cardCount: 7
            )
            PlayerIndicatorView(
                player: Player(id: "2", name: "Sam"),
                isCurrentPlayer: true,
                cardCount: 3
            )
        }
    }
}