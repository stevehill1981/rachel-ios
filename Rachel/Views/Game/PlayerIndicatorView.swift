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
    
    var body: some View {
        VStack(spacing: 8) {
            // Player avatar/icon
            Circle()
                .fill(isCurrentPlayer ? Color.yellow : Color.gray.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay(
                    Text(String(player.name.prefix(1)))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            // Player name
            Text(player.name)
                .font(.caption)
                .foregroundColor(.white)
            
            // Card count
            HStack(spacing: 4) {
                Image(systemName: "rectangle.fill")
                    .font(.caption2)
                Text("\(cardCount)")
                    .font(.caption)
            }
            .foregroundColor(.white.opacity(0.8))
        }
        .scaleEffect(isCurrentPlayer ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: isCurrentPlayer)
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