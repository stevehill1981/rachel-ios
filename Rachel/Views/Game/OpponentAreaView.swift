//
//  OpponentAreaView.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

import SwiftUI

struct OpponentAreaView: View {
    @ObservedObject var engine: GameEngine
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(Array(engine.state.players.enumerated()), id: \.element.id) { index, player in
                if index != 0 { // Don't show the human player here
                    PlayerIndicatorView(
                        player: player,
                        isCurrentPlayer: index == engine.state.currentPlayerIndex,
                        cardCount: player.hand.count
                    )
                }
            }
        }
        .padding()
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
        OpponentAreaView(engine: engine)
    }
}