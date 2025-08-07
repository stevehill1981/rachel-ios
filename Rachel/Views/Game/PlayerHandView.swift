//
//  PlayerHandView.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

import SwiftUI

struct PlayerHandView: View {
    @ObservedObject var engine: GameEngine
    @State private var selectedCardIndices: [Int] = []
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
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
    
    var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Turn indicator - hide in landscape to save space
            if !isLandscape {
                TurnIndicatorView(
                    isPlayerTurn: isPlayerTurn,
                    currentPlayerName: currentPlayer?.name ?? "Unknown"
                )
            }
            
            // Player's cards
            if let player = humanPlayer {
                HandCardsView(
                    cards: player.hand.cards,
                    isPlayerTurn: isPlayerTurn,
                    canPlayCard: { card in
                        engine.canPlay(card: card, playerIndex: 0)
                    },
                    selectedIndices: $selectedCardIndices,
                    onPlayCards: playCards,
                    onDrawCard: drawCard,
                    pendingPickups: engine.state.pendingPickups
                )
            }
        }
    }
    
    private func playCards() {
        if engine.playMultipleCards(indices: selectedCardIndices, by: 0) {
            selectedCardIndices = []
            if !engine.state.needsSuitNomination {
                engine.endTurn()
            }
        } else {
            print("Failed to play selected cards")
        }
    }
    
    private func drawCard() {
        engine.drawCard()
        selectedCardIndices = []
    }
}

struct TurnIndicatorView: View {
    let isPlayerTurn: Bool
    let currentPlayerName: String
    
    var body: some View {
        HStack(spacing: 8) {
            if isPlayerTurn {
                Image(systemName: "hand.point.up.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.yellow)
                Text("Your Turn")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.yellow)
            } else {
                Image(systemName: "clock.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.orange)
                Text("\(currentPlayerName)'s Turn")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isPlayerTurn ? Color.yellow.opacity(0.1) : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            isPlayerTurn ? Color.yellow.opacity(0.3) : Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                )
        )
    }
}

struct HandCardsView: View {
    let cards: [Card]
    let isPlayerTurn: Bool
    let canPlayCard: (Card) -> Bool
    @Binding var selectedIndices: [Int]
    let onPlayCards: () -> Void
    let onDrawCard: () -> Void
    let pendingPickups: Int
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    private var dynamicSpacing: CGFloat {
        // More spacing in landscape since we have more horizontal room
        if isLandscape {
            switch cards.count {
            case 0...1:
                return 0
            case 2...6:
                return -5   // Minimal overlap
            case 7...10:
                return -25  // Light overlap
            case 11...15:
                return -40  // Moderate overlap
            default:
                return -50  // Maximum overlap
            }
        } else {
            // Portrait spacing
            switch cards.count {
            case 0...1:
                return 0
            case 2...4:
                return -10  // Slight overlap
            case 5...7:
                return -35  // Moderate overlap
            case 8...10:
                return -45  // More overlap
            case 11...15:
                return -55  // Heavy overlap
            default:
                return -60  // Maximum overlap
            }
        }
    }
    
    var hasPlayableCards: Bool {
        cards.contains { canPlayCard($0) }
    }
    
    var buttonState: ButtonState {
        if !isPlayerTurn {
            return .notYourTurn
        } else if !selectedIndices.isEmpty {
            return .playCards(selectedIndices.count)
        } else if pendingPickups > 0 {
            return .drawPendingCards(pendingPickups)
        } else if !hasPlayableCards {
            return .drawCard
        } else {
            return .selectCards
        }
    }
    
    enum ButtonState {
        case playCards(Int)
        case drawPendingCards(Int)
        case drawCard
        case selectCards
        case notYourTurn
        
        var text: String {
            switch self {
            case .playCards(let count):
                return "Play \(count) Card\(count == 1 ? "" : "s")"
            case .drawPendingCards(let count):
                return "Draw \(count) Card\(count == 1 ? "" : "s")"
            case .drawCard:
                return "Draw Card"
            case .selectCards:
                return "Select Cards"
            case .notYourTurn:
                return "⏳ Waiting..."
            }
        }
        
        var icon: String {
            switch self {
            case .playCards:
                return "play.fill"
            case .drawPendingCards, .drawCard:
                return "plus.rectangle.fill"
            case .selectCards:
                return "hand.point.up.fill"
            case .notYourTurn:
                return "clock"
            }
        }
        
        var color: Color {
            switch self {
            case .playCards:
                return .green
            case .drawPendingCards:
                return .red
            case .drawCard:
                return .orange
            case .selectCards:
                return .gray
            case .notYourTurn:
                return .gray
            }
        }
        
        var isEnabled: Bool {
            switch self {
            case .selectCards, .notYourTurn:
                return false
            default:
                return true
            }
        }
    }
    
    
    var body: some View {
        if isLandscape {
            // Landscape: cards and button side by side
            HStack(spacing: 16) {
                // Cards
                HStack(spacing: dynamicSpacing) {
                    ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                        cardView(for: card, at: index)
                    }
                }
                .onChange(of: cards.count) { _, _ in
                    selectedIndices = []  // Clear selection when hand changes
                }
                .padding(.leading, 40)
                
                Spacer()
                
                // Action button on the right
                actionButton
                    .padding(.trailing, 40)
            }
        } else {
            // Portrait: vertical layout
            VStack {
                HStack(spacing: dynamicSpacing) {
                    ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                        cardView(for: card, at: index)
                    }
                }
                .onChange(of: cards.count) { _, _ in
                    selectedIndices = []  // Clear selection when hand changes
                }
                .padding(.horizontal, 40)
                
                // Action button below cards
                actionButton
                    .padding(.top, 10)
            }
        }
    }
    
    private func cardView(for card: Card, at index: Int) -> some View {
        let canPlay = isPlayerTurn && canPlayCard(card)
        let isSelected = selectedIndices.contains(index)
        
        // Check if this card can be added to current selection
        let canAddToSelection: Bool = {
            if selectedIndices.isEmpty {
                // First card must be playable (matches top card by suit or rank)
                return canPlay
            } else {
                // Subsequent cards must match the rank of the first selected card
                let firstSelectedIndex = selectedIndices.first!
                let firstSelectedCard = cards[firstSelectedIndex]
                return card.rank == firstSelectedCard.rank
            }
        }()
        
        return ZStack {
            CardView(card: card)
                .frame(height: isLandscape ? 90 : 105)
            
            if !canAddToSelection {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.5))
                    .frame(height: isLandscape ? 90 : 105)
                    .aspectRatio(5/7, contentMode: .fit)
            }
            
            if isSelected {
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(Color.green.opacity(0.6), lineWidth: 3)
                    .frame(height: isLandscape ? 90 : 105)
                    .aspectRatio(5/7, contentMode: .fit)
            } else if canAddToSelection {
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(Color.yellow.opacity(0.4), lineWidth: 2)
                    .frame(height: isLandscape ? 90 : 105)
                    .aspectRatio(5/7, contentMode: .fit)
            }
        }
        .scaleEffect(isSelected ? 1.05 : (canPlay ? 1.0 : 0.95))
        .offset(y: isSelected ? (isLandscape ? -15 : -25) : 0)
        .shadow(
            color: canPlay ? .yellow.opacity(0.3) : .black.opacity(0.1),
            radius: canPlay ? 6 : 2,
            x: 0,
            y: canPlay ? 4 : 1
        )
        .onTapGesture {
            if isPlayerTurn {
                if isSelected {
                    // Deselect if already selected
                    selectedIndices.removeAll { $0 == index }
                } else if canAddToSelection {
                    // Add to selection if valid
                    selectedIndices.append(index)
                }
            }
        }
        .disabled(!isPlayerTurn)
        .animation(.easeInOut(duration: 0.25), value: canPlay)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
    
    private var actionButton: some View {
        Button(action: {
            switch buttonState {
            case .playCards:
                onPlayCards()
            case .drawPendingCards, .drawCard:
                onDrawCard()
            case .selectCards, .notYourTurn:
                break // No action for disabled states
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: buttonState.icon)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(buttonState.text)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(buttonState.color)
                    .shadow(
                        color: buttonState.isEnabled ? buttonState.color.opacity(0.3) : .clear,
                        radius: 6, x: 0, y: 3
                    )
            )
        }
        .disabled(!buttonState.isEnabled || !isPlayerTurn)
    }
}

#Preview {
    let players = [
        Player(id: "1", name: "You"),
        Player(id: "2", name: "Computer", isAI: true)
    ]
    let engine = GameEngine(players: players)
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
