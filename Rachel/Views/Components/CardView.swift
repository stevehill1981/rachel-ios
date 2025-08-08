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
            // Card background
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color(white: 0.98)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            
            // Card border
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(Color.gray.opacity(0.2), lineWidth: 0.5)
            
            // Just the SVG card face (includes corners and center)
            centerSymbols
        }
        .aspectRatio(5/7, contentMode: .fit)
    }
    
    @ViewBuilder
    var centerSymbols: some View {
        Image("\(card.suit.assetName)-\(card.rank.assetName)")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(2)
            .clipShape(RoundedRectangle(cornerRadius: 6))
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
        default: return rawValue
        }
    }
    
    var assetName: String {
        switch self {
        case .ace: return "ace"
        case .king: return "king"
        case .queen: return "queen"
        case .jack: return "jack"
        default: return rawValue
        }
    }
    
    var numericValue: Int {
        switch self {
        case .two: return 2
        case .three: return 3
        case .four: return 4
        case .five: return 5
        case .six: return 6
        case .seven: return 7
        case .eight: return 8
        case .nine: return 9
        case .ten: return 10
        case .jack: return 11
        case .queen: return 12
        case .king: return 13
        case .ace: return 1
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
    
    var symbol: String {
        switch self {
        case .hearts: return "♥"
        case .diamonds: return "♦"
        case .clubs: return "♣"
        case .spades: return "♠"
        }
    }
    
    var assetName: String {
        switch self {
        case .hearts: return "hearts"
        case .diamonds: return "diamonds"
        case .clubs: return "clubs"
        case .spades: return "spades"
        }
    }
    
    var color: Color {
        switch self {
        case .hearts, .diamonds: return .red
        case .clubs, .spades: return .black
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
    ScrollView {
        VStack(spacing: 16) {
            ForEach(Suit.allCases, id: \.self) { suit in
                VStack(spacing: 8) {
                    Text("\(suit.symbol) \(suit.rawValue)")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    // First row: 2, 3, 4, 5
                    HStack(spacing: 8) {
                        CardView(card: Card(rank: .two, suit: suit))
                            .frame(height: 80)
                        CardView(card: Card(rank: .three, suit: suit))
                            .frame(height: 80)
                        CardView(card: Card(rank: .four, suit: suit))
                            .frame(height: 80)
                        CardView(card: Card(rank: .five, suit: suit))
                            .frame(height: 80)
                    }
                    
                    // Second row: 6, 7, 8, 9
                    HStack(spacing: 8) {
                        CardView(card: Card(rank: .six, suit: suit))
                            .frame(height: 80)
                        CardView(card: Card(rank: .seven, suit: suit))
                            .frame(height: 80)
                        CardView(card: Card(rank: .eight, suit: suit))
                            .frame(height: 80)
                        CardView(card: Card(rank: .nine, suit: suit))
                            .frame(height: 80)
                    }
                    
                    // Third row: 10, J, Q, K
                    HStack(spacing: 8) {
                        CardView(card: Card(rank: .ten, suit: suit))
                            .frame(height: 80)
                        CardView(card: Card(rank: .jack, suit: suit))
                            .frame(height: 80)
                        CardView(card: Card(rank: .queen, suit: suit))
                            .frame(height: 80)
                        CardView(card: Card(rank: .king, suit: suit))
                            .frame(height: 80)
                    }
                    
                    // Fourth row: A (centered)
                    HStack(spacing: 8) {
                        Spacer()
                        CardView(card: Card(rank: .ace, suit: suit))
                            .frame(height: 80)
                        Spacer()
                    }
                }
            }
        }
        .padding()
    }
    .background(Color(red: 0.0, green: 0.3, blue: 0.1).ignoresSafeArea())
}