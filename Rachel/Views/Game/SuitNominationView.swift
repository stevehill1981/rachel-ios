//
//  SuitNominationView.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

import SwiftUI

struct SuitNominationView: View {
    let onSelectSuit: (Suit) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose a Suit")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                ForEach(Suit.allCases, id: \.self) { suit in
                    SuitButton(suit: suit) {
                        onSelectSuit(suit)
                    }
                }
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.9))
                .shadow(radius: 20)
        )
    }
}

struct SuitButton: View {
    let suit: Suit
    let action: () -> Void
    
    var suitColor: Color {
        switch suit {
        case .hearts, .diamonds:
            return .red
        case .clubs, .spades:
            return .black
        }
    }
    
    var suitSymbol: String {
        switch suit {
        case .hearts: return "♥"
        case .diamonds: return "♦"
        case .clubs: return "♣"
        case .spades: return "♠"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(suitSymbol)
                    .font(.system(size: 50))
                    .foregroundColor(suitColor)
                
                Text(suit.rawValue.capitalized)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(width: 80, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.95))
                    .shadow(radius: 4)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        Color.green.opacity(0.3)
            .ignoresSafeArea()
        
        SuitNominationView { suit in
            print("Selected: \(suit)")
        }
    }
}