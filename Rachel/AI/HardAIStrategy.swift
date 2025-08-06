//
//  HardAIStrategy.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

struct HardAIStrategy: AIStrategy {
    let name = "Hard AI"
    let description = "Advanced tactics, card counting, and strategic planning"
    
    func decideMove(for player: Player, gameState: GameState) -> AIDecision {
        // Handle pending pickups first
        if gameState.pendingPickups > 0 {
            return .drawCards(gameState.pendingPickups)
        }
        
        // Find playable cards
        guard let topCard = gameState.discardPile.last else { return .drawCard }
        
        let playableCards = player.hand.cards.enumerated().compactMap { index, card in
            GameRules.canPlay(card: card, on: topCard, gameState: gameState) ? 
                (index: index, card: card) : nil
        }
        
        if playableCards.isEmpty {
            return .drawCard
        }
        
        // Analyze game state for strategic decisions
        let analysis = analyzeGameState(player: player, gameState: gameState)
        
        // Check if we can stack cards
        // For each playable card, see if we have other cards of the same rank to stack
        for playableCard in playableCards {
            let rank = playableCard.card.rank
            
            // Find all cards in hand with the same rank
            let sameRankIndices = player.hand.cards.enumerated().compactMap { index, card in
                card.rank == rank ? (index: index, card: card) : nil
            }
            
            if sameRankIndices.count > 1 {
                // We can stack these cards - decide if we should
                let shouldStack = evaluateStrategicStacking(
                    rank: rank,
                    cards: sameRankIndices,
                    gameAnalysis: analysis,
                    player: player,
                    gameState: gameState
                )
                
                if shouldStack.stack {
                    var indicesToPlay = Array(sameRankIndices.map { $0.index }.prefix(shouldStack.count))
                    // Make sure the playable card is first
                    if let playableIndex = indicesToPlay.firstIndex(of: playableCard.index) {
                        indicesToPlay.remove(at: playableIndex)
                        indicesToPlay.insert(playableCard.index, at: 0)
                    }
                    let nominateSuit = rank == .ace ? 
                        selectStrategicSuit(for: player, gameState: gameState, excluding: sameRankIndices[0].card.suit) : nil
                    return .playCards(indices: indicesToPlay, nominateSuit: nominateSuit)
                }
            }
        }
        
        // Single card play - use existing logic
        let chosenCard = selectOptimalCard(from: playableCards, player: player, gameState: gameState)
        
        // If playing an Ace, strategically choose suit to disadvantage next player
        if chosenCard.card.rank == .ace {
            let nominatedSuit = selectStrategicSuit(for: player, gameState: gameState, excluding: chosenCard.card.suit)
            return .playCard(index: chosenCard.index, nominateSuit: nominatedSuit)
        }
        
        return .playCard(index: chosenCard.index, nominateSuit: nil)
    }
    
    private struct GameAnalysis {
        let myCardCount: Int
        let nextPlayerCardCount: Int
        let prevPlayerCardCount: Int
        let closestOpponentCardCount: Int
        let totalPlayersLeft: Int
        let discardPileHistory: [Card]
        let is2sInPlay: Bool
    }
    
    private func analyzeGameState(player: Player, gameState: GameState) -> GameAnalysis {
        let myIndex = gameState.currentPlayerIndex
        let playerCount = gameState.players.count
        
        let nextPlayerIndex = gameState.direction == .clockwise ?
            (myIndex + 1) % playerCount :
            (myIndex - 1 + playerCount) % playerCount
        
        let prevPlayerIndex = gameState.direction == .clockwise ?
            (myIndex - 1 + playerCount) % playerCount :
            (myIndex + 1) % playerCount
        
        let closestOpponent = gameState.players.enumerated()
            .filter { $0.offset != myIndex }
            .min(by: { $0.element.hand.count < $1.element.hand.count })?.element.hand.count ?? 99
        
        let playersWithCards = gameState.players.filter { $0.hand.count > 0 }.count
        
        // Check recent discard history for 2s
        let recentCards = Array(gameState.discardPile.suffix(5))
        let has2sRecently = recentCards.contains { $0.rank == .two }
        
        return GameAnalysis(
            myCardCount: player.hand.count,
            nextPlayerCardCount: gameState.players[nextPlayerIndex].hand.count,
            prevPlayerCardCount: gameState.players[prevPlayerIndex].hand.count,
            closestOpponentCardCount: closestOpponent,
            totalPlayersLeft: playersWithCards,
            discardPileHistory: recentCards,
            is2sInPlay: has2sRecently
        )
    }
    
    private func evaluateStrategicStacking(
        rank: Rank,
        cards: [(index: Int, card: Card)],
        gameAnalysis: GameAnalysis,
        player: Player,
        gameState: GameState
    ) -> (stack: Bool, count: Int) {
        // Advanced stacking logic for Hard AI
        
        // Special handling for 2s
        if rank == .two {
            let total2sInHand = player.hand.cards.filter { $0.rank == .two }.count
            
            // If opponents are close to winning, be aggressive
            if gameAnalysis.closestOpponentCardCount <= 2 {
                // Stack all but one if we have 3+, or all if we have 2
                if total2sInHand >= 3 {
                    return (true, cards.count - 1)
                } else if total2sInHand == 2 {
                    return (true, 2)
                }
                return (false, 0)
            }
            
            // If 2s were played recently, be cautious
            if gameAnalysis.is2sInPlay {
                // Only play one unless we're close to winning
                if gameAnalysis.myCardCount <= 4 {
                    return (true, cards.count)
                }
                return (false, 0)
            }
            
            // Strategic play based on hand size
            if gameAnalysis.myCardCount <= 5 {
                // Close to winning - stack aggressively
                return (true, cards.count)
            } else if gameAnalysis.myCardCount > 10 && total2sInHand > cards.count {
                // Many cards but have backup - stack some
                return (true, min(2, cards.count))
            }
            
            // Default: play one at a time
            return (false, 0)
        }
        
        // Jacks - consider direction impact
        if rank == .jack {
            // If the previous player (who would become next) has few cards, stack them
            if gameAnalysis.prevPlayerCardCount <= 3 {
                return (true, cards.count)
            }
            // If we have many cards, stack to reduce hand
            if gameAnalysis.myCardCount > 8 {
                return (true, cards.count)
            }
            // Otherwise play one
            return (false, 0)
        }
        
        // Queens - skip turns are powerful when used correctly
        if rank == .queen {
            // Stack if next player is close to winning
            if gameAnalysis.nextPlayerCardCount <= 2 {
                return (true, min(2, cards.count)) // Don't skip too many players
            }
            // Or if we need to reduce hand size
            if gameAnalysis.myCardCount > 7 {
                return (true, cards.count)
            }
            return (false, 0)
        }
        
        // Aces - control cards, usually good to keep some
        if rank == .ace {
            // If we're winning, use them
            if gameAnalysis.myCardCount <= 4 {
                return (true, cards.count)
            }
            // Otherwise keep one for control
            if cards.count > 2 {
                return (true, cards.count - 1)
            }
            return (false, 0)
        }
        
        // Normal cards - always stack unless tactical reason not to
        if gameAnalysis.myCardCount <= 3 && gameAnalysis.closestOpponentCardCount <= 3 {
            // End game - be careful about giving opponents options
            return (false, 0)
        }
        
        // Otherwise stack them all
        return (true, cards.count)
    }
    
    private func selectOptimalCard(
        from playableCards: [(index: Int, card: Card)],
        player: Player,
        gameState: GameState
    ) -> (index: Int, card: Card) {
        guard let topCard = gameState.discardPile.last else { return playableCards[0] }
        
        // Analyze game state
        let myCardCount = player.hand.cards.count
        let nextPlayerIndex = gameState.direction == .clockwise ?
            (gameState.currentPlayerIndex + 1) % gameState.players.count :
            (gameState.currentPlayerIndex - 1 + gameState.players.count) % gameState.players.count
        let nextPlayerCardCount = gameState.players[nextPlayerIndex].hand.cards.count
        
        // If next player has few cards, play attack cards
        if nextPlayerCardCount <= 2 {
            if let twoCard = playableCards.first(where: { $0.card.rank == .two }) {
                return twoCard
            }
            if let jackCard = playableCards.first(where: { $0.card.rank == .jack }) {
                return jackCard
            }
        }
        
        // If we have many cards, prioritize getting rid of them
        if myCardCount > 5 {
            // Play Aces to control the game
            if let aceCard = playableCards.first(where: { $0.card.rank == .ace }) {
                return aceCard
            }
            
            // Play high value cards
            if let highCard = playableCards.max(by: { $0.card.rank.numericValue < $1.card.rank.numericValue }) {
                return highCard
            }
        }
        
        // Save special cards for strategic moments
        let normalCards = playableCards.filter { card in
            card.card.rank != .two && card.card.rank != .jack && card.card.rank != .ace
        }
        
        if !normalCards.isEmpty {
            // Play cards that match the current suit to maintain control
            if let suitMatch = normalCards.first(where: { $0.card.suit == topCard.suit }) {
                return suitMatch
            }
            return normalCards[0]
        }
        
        // If only special cards remain, use them wisely
        return playableCards[0]
    }
    
    private func selectStrategicSuit(for player: Player, gameState: GameState, excluding: Suit) -> Suit {
        // Analyze what suits the next player might have based on play history
        // For now, pick the suit we have the least of (to save them for later)
        let suitCounts = player.hand.cards
            .filter { $0.suit != excluding }
            .reduce(into: [:]) { counts, card in
                counts[card.suit, default: 0] += 1
            }
        
        // Pick the least common suit to preserve flexibility
        if let leastCommonSuit = suitCounts.min(by: { $0.value < $1.value })?.key {
            return leastCommonSuit
        } else {
            // Default to a suit we don't have
            let missingSuits = Suit.allCases.filter { suit in
                suit != excluding && !player.hand.cards.contains { $0.suit == suit }
            }
            return missingSuits.randomElement() ?? Suit.allCases.filter { $0 != excluding }.randomElement() ?? .hearts
        }
    }
}