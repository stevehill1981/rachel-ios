//
//  DecorativeCardsView.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

import SwiftUI

struct DecorativeCardsView: View {
    @State private var rotation1: Double = -15
    @State private var rotation2: Double = 0
    @State private var rotation3: Double = 15
    @State private var offset1: CGSize = CGSize(width: -15, height: 0)
    @State private var offset2: CGSize = CGSize(width: 0, height: 0)
    @State private var offset3: CGSize = CGSize(width: 15, height: 0)
    @State private var scale1: CGFloat = 1.0
    @State private var scale2: CGFloat = 1.0
    @State private var scale3: CGFloat = 1.0
    
    let cards = [
        Card(rank: .ace, suit: .hearts),
        Card(rank: .king, suit: .spades),
        Card(rank: .queen, suit: .diamonds)
    ]
    
    var body: some View {
        ZStack {
            // Back card
            CardView(card: cards[0])
                .frame(width: 60, height: 85)
                .scaleEffect(scale1)
                .rotationEffect(.degrees(rotation1))
                .offset(offset1)
                .zIndex(1)
                .shadow(radius: 4)
            
            // Middle card
            CardView(card: cards[1])
                .frame(width: 60, height: 85)
                .scaleEffect(scale2)
                .rotationEffect(.degrees(rotation2))
                .offset(offset2)
                .zIndex(2)
                .shadow(radius: 4)
            
            // Front card
            CardView(card: cards[2])
                .frame(width: 60, height: 85)
                .scaleEffect(scale3)
                .rotationEffect(.degrees(rotation3))
                .offset(offset3)
                .zIndex(3)
                .shadow(radius: 4)
        }
        .onAppear {
            animateCards()
        }
    }
    
    private func animateCards() {
        // Card 1 - gentle sway
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            rotation1 = -18
            offset1 = CGSize(width: -25, height: -8)
            scale1 = 0.95
        }
        
        // Card 2 - different timing
        withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
            rotation2 = 8
            offset2 = CGSize(width: 5, height: 10)
            scale2 = 1.05
        }
        
        // Card 3 - faster movement
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            rotation3 = 20
            offset3 = CGSize(width: 22, height: -5)
            scale3 = 0.98
        }
    }
}

struct CardView: View {
    let card: Card
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(radius: 3)
            
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
            
            VStack(spacing: 4) {
                Text(card.rank.display)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(card.suit.isRed ? .red : .black)
                
                Text(card.suit.display)
                    .font(.system(size: 20))
            }
        }
    }
}

// Add display properties to Rank
extension Rank {
    var display: String {
        switch self {
        case .ace: return "A"
        case .king: return "K"
        case .queen: return "Q"
        case .jack: return "J"
        default: return "\(rawValue)"
        }
    }
}

// Add display and color properties to Suit
extension Suit {
    var display: String {
        switch self {
        case .hearts: return "♥️"
        case .diamonds: return "♦️"
        case .clubs: return "♣️"
        case .spades: return "♠️"
        }
    }
    
    var isRed: Bool {
        switch self {
        case .hearts, .diamonds: return true
        case .clubs, .spades: return false
        }
    }
}

#Preview {
    ZStack {
        BaizeBackground()
        DecorativeCardsView()
    }
}