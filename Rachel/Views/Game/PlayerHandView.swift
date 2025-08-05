//
//  PlayerHandView.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

import SwiftUI

struct PlayerHandView: View {
    @ObservedObject var engine: GameEngine
    
    var currentPlayer: Player? {
        guard engine.state.currentPlayerIndex < engine.state.players.count else { return nil }
        return engine.state.players[engine.state.currentPlayerIndex]
    }
    
    var isPlayerTurn: Bool {
        engine.state.currentPlayerIndex == 0
    }
    
    var humanPlayer: Player? {
        engine.state.players.first
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Turn indicator
            TurnIndicatorView(
                isPlayerTurn: isPlayerTurn,
                currentPlayerName: currentPlayer?.name ?? "Unknown"
            )
            
            // Player's cards
            if let player = humanPlayer {
                HandCardsView(
                    cards: player.hand.cards,
                    isPlayerTurn: isPlayerTurn,
                    canPlayCard: { card in
                        engine.canPlay(card: card, playerIndex: 0)
                    },
                    onCardTap: { index in
                        if isPlayerTurn {
                            _ = engine.playCard(at: index, by: 0)
                        }
                    }
                )
            }
        }
    }
}

struct TurnIndicatorView: View {
    let isPlayerTurn: Bool
    let currentPlayerName: String
    
    var body: some View {
        HStack(spacing: 8) {
            if isPlayerTurn {
                Image(systemName: "hand.point.up.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.yellow)
                Text("Your Turn")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.yellow)
            } else {
                Image(systemName: "clock.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.orange)
                Text("\(currentPlayerName)'s Turn")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isPlayerTurn ? Color.yellow.opacity(0.1) : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            isPlayerTurn ? Color.yellow.opacity(0.3) : Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                )
        )
    }
}

struct HandCardsView: View {
    let cards: [Card]
    let isPlayerTurn: Bool
    let canPlayCard: (Card) -> Bool
    let onCardTap: (Int) -> Void
    
    @State private var selectedCardIndex: Int? = nil
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: -25) {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    let canPlay = isPlayerTurn && canPlayCard(card)
                    let isSelected = selectedCardIndex == index
                    
                    CardView(card: card)
                        .frame(height: 91)
                        .scaleEffect(isSelected ? 1.05 : (canPlay ? 1.0 : 0.95))
                        .offset(y: canPlay ? -12 : (isSelected ? -8 : 0))
                        .shadow(
                            color: canPlay ? .yellow.opacity(0.3) : .black.opacity(0.2),
                            radius: canPlay ? 6 : 3,
                            x: 0,
                            y: canPlay ? 4 : 2
                        )
                        .overlay(
                            canPlay ? 
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.yellow.opacity(0.4), lineWidth: 2)
                            : nil
                        )
                        .zIndex(canPlay ? 1 : 0)
                        .onTapGesture {
                            if isPlayerTurn {
                                selectedCardIndex = index
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    onCardTap(index)
                                    selectedCardIndex = nil
                                }
                            }
                        }
                        .disabled(!isPlayerTurn)
                        .animation(.easeInOut(duration: 0.25), value: canPlay)
                        .animation(.easeInOut(duration: 0.15), value: isSelected)
                }
            }
            .padding(.horizontal, 50)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, 10)
    }
}

#Preview {
    let players = [
        Player(id: "1", name: "You"),
        Player(id: "2", name: "Computer", isAI: true)
    ]
    var engine = GameEngine(players: players)
    engine.dealCards()
    
    return ZStack {
        BaizeBackground()
        VStack {
            Spacer()
            PlayerHandView(engine: engine)
                .padding()
        }
    }
}