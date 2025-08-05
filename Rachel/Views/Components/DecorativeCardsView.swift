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
                .frame(height: 84)
                .scaleEffect(scale1)
                .rotationEffect(.degrees(rotation1))
                .offset(offset1)
                .zIndex(1)
                .shadow(radius: 4)
            
            // Middle card
            CardView(card: cards[1])
                .frame(height: 84)
                .scaleEffect(scale2)
                .rotationEffect(.degrees(rotation2))
                .offset(offset2)
                .zIndex(2)
                .shadow(radius: 4)
            
            // Front card
            CardView(card: cards[2])
                .frame(height: 84)
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


#Preview {
    ZStack {
        BaizeBackground()
        DecorativeCardsView()
    }
}