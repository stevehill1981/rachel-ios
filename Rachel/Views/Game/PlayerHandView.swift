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
        if isPlayerTurn {
            Text("Your Turn")
                .font(.headline)
                .foregroundColor(.yellow)
        } else {
            Text("\(currentPlayerName)'s Turn")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

struct HandCardsView: View {
    let cards: [Card]
    let isPlayerTurn: Bool
    let canPlayCard: (Card) -> Bool
    let onCardTap: (Int) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: -20) {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    CardView(card: card)
                        .frame(width: 70, height: 100)
                        .offset(y: isPlayerTurn && canPlayCard(card) ? -10 : 0)
                        .onTapGesture {
                            onCardTap(index)
                        }
                        .disabled(!isPlayerTurn)
                        .animation(.easeInOut(duration: 0.2), value: isPlayerTurn && canPlayCard(card))
                }
            }
            .padding(.horizontal, 40)
        }
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