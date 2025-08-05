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
        HStack(spacing: 50) {
            // Draw pile
            DrawPileView {
                engine.drawCard()
            }
            
            // Discard pile with glow effect
            DiscardPileView(
                topCard: topCard,
                nominatedSuit: engine.state.nominatedSuit
            )
            
            // Game info
            GameInfoView(
                pendingPickups: engine.state.pendingPickups,
                skipNextPlayer: engine.state.pendingSkips > 0
            )
        }
    }
}

struct CenterCardAreaView: View {
    @ObservedObject var engine: GameEngine
    
    var topCard: Card? {
        engine.state.discardPile.last
    }
    
    var body: some View {
        HStack(spacing: 50) {
            // Draw pile
            DrawPileView {
                engine.drawCard()
            }
            
            // Discard pile with glow effect
            DiscardPileView(
                topCard: topCard,
                nominatedSuit: engine.state.nominatedSuit
            )
        }
    }
}

struct DrawPileView: View {
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.9), Color.blue.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .aspectRatio(5/7, contentMode: .fit)
                    .frame(height: 112)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .overlay(
                        VStack(spacing: 2) {
                            Image(systemName: "questionmark")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            Text("DRAW")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    )
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .offset(x: CGFloat(i * 3), y: CGFloat(i * 2))
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
                    .frame(height: 112)
                    .shadow(color: .yellow.opacity(0.3), radius: 8, x: 0, y: 0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.yellow.opacity(0.4), lineWidth: 2)
                    )
                
                if let suit = nominatedSuit {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            VStack(spacing: 2) {
                                Text(suit.symbol)
                                    .font(.title2)
                                    .foregroundColor(suit.color)
                                Text("SUIT")
                                    .font(.system(size: 8, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.black.opacity(0.8))
                            )
                        }
                    }
                    .padding(4)
                }
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.5), Color.white.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .aspectRatio(5/7, contentMode: .fit)
                    .frame(height: 112)
                    .overlay(
                        VStack(spacing: 4) {
                            Image(systemName: "tray")
                                .font(.system(size: 24, weight: .light))
                                .foregroundColor(.white.opacity(0.4))
                            Text("DISCARD")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.4))
                        }
                    )
            }
        }
    }
}

struct GameInfoView: View {
    let pendingPickups: Int
    let skipNextPlayer: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            if pendingPickups > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.yellow)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(pendingPickups) Pickups")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.yellow)
                        Text("Pending")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(.yellow.opacity(0.8))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.yellow.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            
            if skipNextPlayer {
                HStack(spacing: 8) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.orange)
                    Text("Skip Pending")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
        .padding(.top, 8)
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