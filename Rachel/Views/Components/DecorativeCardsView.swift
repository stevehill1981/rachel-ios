//
//  DecorativeCardsView.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

import SwiftUI

enum DecorativeStyle {
    case cascade
    case fan
    case stack
    case circle3D
    case spiral
}

struct DecorativeCardsView: View {
    @State private var cardStates: [CardState] = []
    @State private var isAnimating = false
    @State private var showSparkle = false
    @State private var currentCardSet = 0
    @State private var timers: [Timer] = []
    @State private var circleRotation: Double = 0
    @State private var cards: [Card] = []
    
    var style: DecorativeStyle = .cascade
    
    // Number of cards based on style
    private var cardCount: Int {
        switch style {
        case .cascade, .fan, .stack:
            return 3
        case .circle3D:
            return 20  // Show 20 cards for a fuller circle
        case .spiral:
            return 8
        }
    }
    
    let cardSets = [
        [
            Card(rank: .ace, suit: .hearts),
            Card(rank: .king, suit: .spades),
            Card(rank: .queen, suit: .diamonds)
        ],
        [
            Card(rank: .jack, suit: .clubs),
            Card(rank: .ace, suit: .spades),
            Card(rank: .king, suit: .hearts)
        ],
        [
            Card(rank: .two, suit: .diamonds),
            Card(rank: .queen, suit: .clubs),
            Card(rank: .ace, suit: .diamonds)
        ]
    ]
    
    struct CardState {
        var rotation: Double = 0
        var offset: CGSize = .zero
        var scale: CGFloat = 0.1
        var opacity: Double = 0
        var flipRotation: Double = 0
        var zIndex: Double = 0
        var glow: Bool = false
    }
    
    var body: some View {
        ZStack {
            // Sparkle effect background
            if showSparkle && style != .circle3D {
                SparkleEffect()
                    .transition(.opacity)
            }
            
            if style == .circle3D {
                // 3D Circle view
                Circle3DView(cards: cards, rotation: circleRotation)
                    .frame(height: 150)
            } else {
                // Other styles
                ForEach(cardStates.indices, id: \.self) { index in
                    if index < cards.count {
                        EnhancedCardView(
                            card: cards[index],
                            state: cardStates[index]
                        )
                        .frame(height: 84)
                        .zIndex(cardStates[index].zIndex)
                    }
                }
            }
        }
        .onAppear {
            generateCards()
            setupInitialStates()
            startAnimationSequence()
        }
        .onDisappear {
            cleanupTimers()
        }
    }
    
    private func generateCards() {
        switch style {
        case .cascade, .fan, .stack:
            cards = cardSets[currentCardSet]
        case .circle3D, .spiral:
            // Generate a variety of cards for 3D effects
            var generatedCards: [Card] = []
            let suits = Suit.allCases
            let ranks: [Rank] = [.ace, .king, .queen, .jack, .ten, .nine, .eight, .seven, .six, .five, .four, .three, .two]
            
            for i in 0..<cardCount {
                let suit = suits[i % suits.count]
                let rank = ranks[i % ranks.count]
                generatedCards.append(Card(rank: rank, suit: suit))
            }
            cards = generatedCards
        }
    }
    
    private func setupInitialStates() {
        switch style {
        case .cascade:
            cardStates = [
                CardState(rotation: -25, offset: CGSize(width: -30, height: -10), zIndex: 1),
                CardState(rotation: 0, offset: CGSize(width: 0, height: 0), zIndex: 2),
                CardState(rotation: 25, offset: CGSize(width: 30, height: -10), zIndex: 3)
            ]
        case .fan:
            cardStates = [
                CardState(rotation: -45, offset: CGSize(width: -40, height: 20), zIndex: 1),
                CardState(rotation: 0, offset: CGSize(width: 0, height: 0), zIndex: 3),
                CardState(rotation: 45, offset: CGSize(width: 40, height: 20), zIndex: 2)
            ]
        case .stack:
            cardStates = [
                CardState(rotation: -5, offset: CGSize(width: -2, height: -4), zIndex: 1),
                CardState(rotation: 0, offset: CGSize(width: 0, height: 0), zIndex: 2),
                CardState(rotation: 5, offset: CGSize(width: 2, height: 4), zIndex: 3)
            ]
        case .circle3D:
            // Circle3D handles its own positioning
            cardStates = []
        case .spiral:
            cardStates = []
            for i in 0..<cardCount {
                let angle = Double(i) * (360.0 / Double(cardCount))
                let radius = 20.0 + Double(i) * 8.0
                let x = radius * cos(angle * .pi / 180)
                let y = radius * sin(angle * .pi / 180)
                cardStates.append(
                    CardState(
                        rotation: angle,
                        offset: CGSize(width: x, height: y),
                        scale: 0.8 + Double(i) * 0.03,
                        zIndex: Double(i)
                    )
                )
            }
        }
    }
    
    private func startAnimationSequence() {
        if style == .circle3D {
            // Start 3D circle rotation with variable speed
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                circleRotation = 360
            }
            
            // Add speed variations
            Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 2)) {
                    // Speed variations are handled by the animation system
                }
            }
        } else {
            // Initial cascade entrance for other styles
            for (index, _) in cardStates.enumerated() {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.15)) {
                    cardStates[index].scale = 1.0
                    cardStates[index].opacity = 1.0
                }
            }
            
            // Start continuous animations after entrance
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                startContinuousAnimations()
                if style != .spiral {
                    startPeriodicEffects()
                }
            }
        }
    }
    
    private func startContinuousAnimations() {
        // Floating animation for each card
        for index in cardStates.indices {
            let duration = 3.0 + Double(index) * 0.5
            let delay = Double(index) * 0.2
            
            withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true).delay(delay)) {
                cardStates[index].offset.height += CGFloat.random(in: -15...15)
                cardStates[index].rotation += Double.random(in: -5...5)
            }
        }
    }
    
    private func startPeriodicEffects() {
        // Periodic card flip
        let flipTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { _ in
            performCardFlip()
        }
        timers.append(flipTimer)
        
        // Periodic sparkle
        let sparkleTimer = Timer.scheduledTimer(withTimeInterval: 12.0, repeats: true) { _ in
            performSparkle()
        }
        timers.append(sparkleTimer)
        
        // Periodic shuffle
        let shuffleTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { _ in
            performShuffle()
        }
        timers.append(shuffleTimer)
    }
    
    private func cleanupTimers() {
        timers.forEach { $0.invalidate() }
        timers.removeAll()
    }
    
    private func performCardFlip() {
        guard style != .circle3D && style != .spiral else { return }
        
        let randomIndex = Int.random(in: 0..<cardStates.count)
        
        withAnimation(.easeInOut(duration: 0.6)) {
            cardStates[randomIndex].flipRotation += 180
        }
        
        // Change card set mid-flip
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentCardSet = (currentCardSet + 1) % cardSets.count
            generateCards()
        }
    }
    
    private func performSparkle() {
        withAnimation(.easeIn(duration: 0.3)) {
            showSparkle = true
        }
        
        // Make a random card glow
        let randomIndex = Int.random(in: 0..<cardStates.count)
        withAnimation(.easeInOut(duration: 1.0)) {
            cardStates[randomIndex].glow = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.3)) {
                showSparkle = false
                cardStates[randomIndex].glow = false
            }
        }
    }
    
    private func performShuffle() {
        // Gather cards to center
        withAnimation(.easeInOut(duration: 0.4)) {
            for index in cardStates.indices {
                cardStates[index].offset = .zero
                cardStates[index].rotation = 0
                cardStates[index].scale = 0.8
            }
        }
        
        // Shuffle and spread based on style
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                switch style {
                case .cascade:
                    cardStates[0].offset = CGSize(width: -30, height: -10)
                    cardStates[0].rotation = -25
                    cardStates[1].offset = CGSize(width: 0, height: 0)
                    cardStates[1].rotation = 0
                    cardStates[2].offset = CGSize(width: 30, height: -10)
                    cardStates[2].rotation = 25
                case .fan:
                    cardStates[0].offset = CGSize(width: -40, height: 20)
                    cardStates[0].rotation = -45
                    cardStates[1].offset = CGSize(width: 0, height: 0)
                    cardStates[1].rotation = 0
                    cardStates[2].offset = CGSize(width: 40, height: 20)
                    cardStates[2].rotation = 45
                case .stack:
                    cardStates[0].offset = CGSize(width: -2, height: -4)
                    cardStates[0].rotation = -5
                    cardStates[1].offset = CGSize(width: 0, height: 0)
                    cardStates[1].rotation = 0
                    cardStates[2].offset = CGSize(width: 2, height: 4)
                    cardStates[2].rotation = 5
                case .circle3D:
                    break // Circle3D handles its own animations
                case .spiral:
                    for i in 0..<cardCount {
                        let angle = Double(i) * (360.0 / Double(cardCount))
                        let radius = 20.0 + Double(i) * 8.0
                        let x = radius * cos(angle * .pi / 180)
                        let y = radius * sin(angle * .pi / 180)
                        cardStates[i].offset = CGSize(width: x, height: y)
                        cardStates[i].rotation = angle
                    }
                }
                
                // Randomize z-order for all styles
                for index in cardStates.indices {
                    cardStates[index].scale = 1.0
                    cardStates[index].zIndex = Double.random(in: 1...3)
                }
            }
        }
    }
}

struct EnhancedCardView: View {
    let card: Card
    let state: DecorativeCardsView.CardState
    
    var body: some View {
        CardView(card: card)
            .scaleEffect(state.scale)
            .rotationEffect(.degrees(state.rotation))
            .rotation3DEffect(
                .degrees(state.flipRotation),
                axis: (x: 0, y: 1, z: 0)
            )
            .offset(state.offset)
            .opacity(state.opacity)
            .shadow(
                color: state.glow ? Color.yellow.opacity(0.6) : Color.black.opacity(0.3),
                radius: state.glow ? 12 : 4,
                x: 0,
                y: 4
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        LinearGradient(
                            colors: state.glow ? [Color.yellow, Color.orange] : [Color.clear, Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: state.glow ? 2 : 0
                    )
                    .opacity(state.glow ? 0.8 : 0)
                    .blur(radius: state.glow ? 2 : 0)
            )
    }
}

struct Circle3DView: View {
    let cards: [Card]
    let rotation: Double
    
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Inner glow circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.yellow.opacity(0.3),
                                Color.orange.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .scaleEffect(pulseScale)
                    .blur(radius: 10)
                
                // Cards arranged in circle
                ForEach(cards.indices, id: \.self) { index in
                    let angle = (Double(index) / Double(cards.count)) * 360.0 + rotation
                    let radians = angle * .pi / 180
                    let radius: CGFloat = 100
                    let depth = sin(radians) // Creates 3D effect
                    let scale = 0.7 + 0.3 * ((depth + 1) / 2) // Scale based on depth
                    let opacity = 0.5 + 0.5 * ((depth + 1) / 2) // Opacity based on depth
                    
                    CardView(card: cards[index])
                        .frame(height: 65)
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .rotation3DEffect(
                            .degrees(angle - 90),
                            axis: (x: 0, y: 1, z: 0),
                            perspective: 0.4
                        )
                        .offset(
                            x: radius * cos(radians),
                            y: radius * sin(radians) * 0.25 // Flatten the circle vertically
                        )
                        .zIndex(depth * 100) // Ensure proper layering
                        .shadow(
                            color: Color.black.opacity(0.4 * opacity),
                            radius: 5 * scale,
                            x: 0,
                            y: 5 * scale
                        )
                        .overlay(
                            // Add shimmer effect to front cards
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(depth > 0.5 ? 0.2 : 0),
                                            Color.clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .allowsHitTesting(false)
                        )
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .rotation3DEffect(
                .degrees(20), // Tilt the entire circle more dramatically
                axis: (x: 1, y: 0, z: 0),
                perspective: 0.8
            )
            .onAppear {
                // Add subtle pulse animation
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    pulseScale = 1.1
                }
            }
        }
    }
}

struct SparkleEffect: View {
    @State private var sparklePositions: [CGPoint] = []
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<8, id: \.self) { index in
                Image(systemName: "sparkle")
                    .font(.system(size: CGFloat.random(in: 8...16)))
                    .foregroundColor(.yellow)
                    .opacity(Double.random(in: 0.3...0.8))
                    .position(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: 0...geometry.size.height)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 0.5...1.5))
                            .repeatForever(autoreverses: true),
                        value: sparklePositions
                    )
            }
        }
    }
}


#Preview("Cascade Style") {
    ZStack {
        Color(red: 0.0, green: 0.3, blue: 0.1)
            .ignoresSafeArea()
        DecorativeCardsView(style: .cascade)
    }
}

#Preview("Fan Style") {
    ZStack {
        Color(red: 0.0, green: 0.3, blue: 0.1)
            .ignoresSafeArea()
        DecorativeCardsView(style: .fan)
    }
}

#Preview("Stack Style") {
    ZStack {
        Color(red: 0.0, green: 0.3, blue: 0.1)
            .ignoresSafeArea()
        DecorativeCardsView(style: .stack)
    }
}

#Preview("3D Circle") {
    ZStack {
        Color(red: 0.0, green: 0.3, blue: 0.1)
            .ignoresSafeArea()
        DecorativeCardsView(style: .circle3D)
            .frame(height: 200)
    }
}

#Preview("Spiral Style") {
    ZStack {
        Color(red: 0.0, green: 0.3, blue: 0.1)
            .ignoresSafeArea()
        DecorativeCardsView(style: .spiral)
    }
}