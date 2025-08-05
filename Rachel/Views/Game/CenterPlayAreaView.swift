//
//  CenterPlayAreaView.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

import SwiftUI

struct CenterPlayAreaView: View {
    @ObservedObject var engine: GameEngine
    
    var topCard: Card? {
        engine.state.discardPile.last
    }
    
    var body: some View {
        HStack(spacing: 40) {
            // Draw pile
            DrawPileView {
                engine.drawCard()
            }
            
            // Discard pile
            DiscardPileView(
                topCard: topCard,
                nominatedSuit: engine.state.nominatedSuit
            )
            
            // Game info
            GameInfoView(
                pendingPickups: engine.state.pendingPickups,
                skipNextPlayer: engine.state.pendingSkips > 0,
                direction: engine.state.direction
            )
        }
    }
}

struct DrawPileView: View {
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.8))
                    .frame(width: 70, height: 100)
                    .overlay(
                        Text("?")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    )
                    .offset(x: CGFloat(i * 2), y: CGFloat(i * 2))
            }
        }
        .onTapGesture {
            onTap()
        }
    }
}

struct DiscardPileView: View {
    let topCard: Card?
    let nominatedSuit: Suit?
    
    var body: some View {
        ZStack {
            if let card = topCard {
                CardView(card: card)
                    .frame(width: 70, height: 100)
                
                if let suit = nominatedSuit {
                    VStack {
                        Spacer()
                        Text(suit.display)
                            .font(.title)
                            .padding(4)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(4)
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    .frame(width: 70, height: 100)
            }
        }
    }
}

struct GameInfoView: View {
    let pendingPickups: Int
    let skipNextPlayer: Bool
    let direction: Direction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if pendingPickups > 0 {
                Label("\(pendingPickups) pickups!", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
            
            if skipNextPlayer {
                Label("Skip pending", systemImage: "forward.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            
            Label(direction == .clockwise ? "Clockwise" : "Counter", 
                  systemImage: direction == .clockwise ? "arrow.clockwise" : "arrow.counterclockwise")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
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
        CenterPlayAreaView(engine: engine)
    }
}