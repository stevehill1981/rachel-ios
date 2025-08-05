//
//  CardView.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

import SwiftUI

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
    HStack(spacing: 20) {
        CardView(card: Card(rank: .ace, suit: .hearts))
        CardView(card: Card(rank: .king, suit: .spades))
        CardView(card: Card(rank: .two, suit: .diamonds))
    }
    .padding()
    .background(BaizeBackground())
}