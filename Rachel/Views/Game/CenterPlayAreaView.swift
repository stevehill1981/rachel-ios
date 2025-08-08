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
                nominatedSuit: engine.state.nominatedSuit,
                discardPile: engine.state.discardPile
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
        HStack(spacing: 40) {
            Spacer()
            
            // Draw pile
            DrawPileView {
                engine.drawCard()
            }
            .frame(width: 100)
            
            // Discard pile with glow effect
            DiscardPileView(
                topCard: topCard,
                nominatedSuit: engine.state.nominatedSuit,
                discardPile: engine.state.discardPile
            )
            .frame(width: 100)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct DrawPileView: View {
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        CardBackView()
            .frame(height: 140)
            .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 3)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
                
                onTap()
            }
    }
}

struct DiscardPileView: View {
    let topCard: Card?
    let nominatedSuit: Suit?
    let discardPile: [Card]
    
    var body: some View {
        ZStack {
            if let _ = topCard {
                // Show bottom cards with slight rotation and offset
                let cardsToShow = min(4, discardPile.count)
                let startIndex = max(0, discardPile.count - cardsToShow)
                
                ForEach(startIndex..<discardPile.count, id: \.self) { index in
                    let cardIndex = index - startIndex
                    let card = discardPile[index]
                    // Use card ID hash for consistent rotation
                    let hashValue = abs(card.id.hashValue)
                    let rotation = Double(hashValue % 17 - 8) * (1.0 - Double(cardIndex) / Double(cardsToShow))
                    let offsetX = CGFloat(hashValue % 7 - 3)
                    let offsetY = CGFloat(cardIndex) * -2
                    
                    CardView(card: card)
                        .frame(height: 140)
                        .rotationEffect(.degrees(rotation))
                        .offset(x: offsetX, y: offsetY)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                        .zIndex(Double(cardIndex))
                }
                
                
                // Nominated suit indicator
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
                    .zIndex(Double(cardsToShow + 1))
                }
            } else {
                // Empty discard pile
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.5), Color.white.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 2, dash: [5, 3])
                    )
                    .aspectRatio(5/7, contentMode: .fit)
                    .frame(height: 140)
                    .overlay(
                        VStack(spacing: 4) {
                            Image(systemName: "arrow.down.square")
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
    ZStack {
        BaizeBackground()
        CenterPlayAreaView(engine: {
            let players = [
                Player(id: "1", name: "You"),
                Player(id: "2", name: "Computer", isAI: true)
            ]
            let engine = GameEngine(players: players)
            engine.dealCards()
            return engine
        }())
    }
}