//
//  HardAI.swift
//  Penumbral
//
//  Created by Braxton Smallwood on 1/16/25.
//

class HardAI: EnemyAI {
    private var knownCards: [Card] = []
    private var roundsStartedWithNight = 0
    
    // Slightly adjusted personality traits
    var bankingProbability: Double { return 0.35 }  // Reduced from 0.4 since banking is more vulnerable
    var aggressiveness: Double { return 0.7 }      // Keep high aggression
    var prefersHighCards: Bool { return true }
    
    // Enhanced game state analysis for best-of-5 format
    private func analyzeGameState(_ gameState: GameState) -> (
        isCritical: Bool,
        shouldBeAggressive: Bool,
        needsComeback: Bool,
        roundImportance: Double
    ) {
        let playerWins = gameState.scoreState.playerRoundsWon
        let enemyWins = gameState.scoreState.enemyRoundsWon
        let currentRound = gameState.scoreState.currentRound
        let handsInRound = gameState.scoreState.playerHandsWon + gameState.scoreState.enemyHandsWon
        let playerBankedPower = gameState.player.bankedPower ?? 0
        
        // Analyze round importance based on match state
        let roundImportance = switch (playerWins, enemyWins) {
        case (2, _):  // Must win to stay alive
            2.0
        case (_, 2):  // Can win match
            1.8
        case (1, 1):  // Crucial middle round
            1.5
        case (1, 0), (0, 1):  // Important momentum round
            1.3
        default:  // Opening round
            1.0
        }
        
        // Determine if this is a critical situation
        let isCritical = playerWins == 2 ||  // Match point for opponent
                        playerBankedPower > 8 ||  // High opponent bank
                        (handsInRound >= 3 && gameState.scoreState.playerHandsWon > gameState.scoreState.enemyHandsWon)  // Late in round and behind
        
        // Determine if we need to play aggressively
        let shouldBeAggressive = playerWins > enemyWins ||  // Behind in match
                                gameState.scoreState.playerHandPoints > gameState.scoreState.enemyHandPoints + 4 ||  // Behind in hand
                                (currentRound >= 3 && enemyWins < 2)  // Late in match without advantage
        
        // Determine if we need a comeback
        let needsComeback = playerWins > enemyWins &&  // Behind in match
                           (currentRound >= 2 || gameState.scoreState.playerHandsWon > gameState.scoreState.enemyHandsWon)  // Late in match or round
        
        return (isCritical, shouldBeAggressive, needsComeback, roundImportance)
    }
    
    // Enhanced first card evaluation for new scoring system
    private func evaluateFirstCardOptions(hand: [Card], gameState: GameState) -> [(card: Card, value: Double)] {
        let state = analyzeGameState(gameState)
        let remaining = analyzeRemainingDeck(gameState)
        
        // Count cards by suit in hand for combination potential
        let duskCards = hand.filter { $0.suit == .dusk }
        let nightCards = hand.filter { $0.suit == .night }
        let dawnCards = hand.filter { $0.suit == .dawn }
        
        return hand.map { card in
            var value = Double(card.value)
            
            // Base value multiplier based on game state
            value *= state.roundImportance
            
            switch card.suit {
            case .dawn:
                // Dawn first gives immediate points but doesn't double if followed by others
                if state.shouldBeAggressive {
                    value *= 1.3
                    if dawnCards.count > 1 {  // Potential for Dawn+Dawn
                        value *= 1.4
                    }
                }
                
                // Save high Dawn cards for critical situations
                if card.value >= 6 && !state.isCritical {
                    value *= 0.8
                }
                
            case .night:
                // Night first only banks base value unless followed by Night
                if nightCards.count > 1 {  // Potential for Night+Night
                    value *= 1.5
                } else if !state.shouldBeAggressive {
                    value *= 1.2  // Decent banking option
                }
                
                // Avoid being too predictable with Night starts
                if roundsStartedWithNight >= 2 {
                    value *= 0.8
                }
                
            case .dusk:
                // Dusk first prevents opponent's power use
                if gameState.player.bankedPower ?? 0 > 0 {
                    value *= 1.4  // Very valuable to lock opponent's power
                    if duskCards.count > 1 {  // Potential for Dusk+Dusk
                        value *= 1.3
                    }
                } else if duskCards.count > 1 {
                    value *= 1.2  // Still good for Dusk+Dusk scoring
                }
            }
            
            // Consider card saving for crucial situations
            if state.needsComeback && card.value >= 6 {
                value *= 0.9  // Save some high cards for later
            }
            
            // Add controlled randomness
            value *= Double.random(in: 0.95...1.05)
            
            return (card, value)
        }
    }
    
    // Enhanced second card evaluation for new scoring mechanics
    private func evaluateSecondCardOptions(
        hand: [Card],
        firstCard: Card,
        gameState: GameState
    ) -> [(card: Card, value: Double)] {
        let state = analyzeGameState(gameState)
        
        return hand.map { card in
            var value = Double(card.value)
            let combination = CardCombination(firstCard: firstCard, secondCard: card)
            
            // Base value multiplier based on game state
            value *= state.roundImportance
            
            // Same suit combinations
            if card.suit == firstCard.suit {
                switch card.suit {
                case .dawn:
                    // Dawn+Dawn doubles sum
                    value *= 2.0
                    if state.shouldBeAggressive {
                        value *= 1.3
                    }
                case .night:
                    // Night+Night doubles sum for banking
                    value *= 1.8
                    if !state.shouldBeAggressive {
                        value *= 1.2
                    }
                case .dusk:
                    // Dusk+Dusk scores and cancels
                    value *= 1.6
                    if gameState.player.bankedPower ?? 0 > 0 {
                        value *= 1.3
                    }
                }
            } else {
                // Cross-suit combinations - second card gets doubled
                switch card.suit {
                case .dawn:
                    // Second Dawn doubles points
                    value *= 1.8
                    if state.shouldBeAggressive {
                        value *= 1.2
                    }
                case .night:
                    // Second Night doubles banking
                    value *= 1.6
                    if !state.needsComeback {
                        value *= 1.2
                    }
                case .dusk:
                    // Second Dusk doubles cancellation
                    if firstCard.suit == .night {
                        // For Night+Dusk, only value the cancellation
                        value *= 1.2  // Reduced multiplier since no scoring
                        if gameState.player.bankedPower ?? 0 > 0 {
                            value *= 1.4  // Higher value if there's power to cancel
                        }
                    } else {
                        // For Dawn+Dusk, normal evaluation
                        value *= 1.4
                        if gameState.player.bankedPower ?? 0 > 0 {
                            value *= 1.3
                        }
                    }
                }
            }
            
            // Consider immediate game state needs
            if state.isCritical && combination.calculateImmediatePoints() > 0 {
                value *= 1.3  // Prioritize immediate points in critical situations
            }
            
            if state.needsComeback && combination.calculateImmediatePoints() > combination.calculateBankedPoints() {
                value *= 1.2  // Prefer immediate points when needing comeback
            }
            
            // Add controlled randomness
            value *= Double.random(in: 0.95...1.05)
            
            return (card, value)
        }
    }
    
    func selectFirstCard(from hand: [Card], gameState: GameState) -> Card {
        let options = evaluateFirstCardOptions(hand: hand, gameState: gameState)
        let selectedCard = options.max(by: { $0.value < $1.value })?.card ?? hand.first!
        
        // Track Night card usage
        if selectedCard.suit == .night && gameState.playerFaceUpCard == nil {
            roundsStartedWithNight += 1
        }
        
        knownCards.append(selectedCard)
        return selectedCard
    }
    
    func selectSecondCard(hand: [Card], firstCard: Card, gameState: GameState) -> Card {
        let options = evaluateSecondCardOptions(hand: hand, firstCard: firstCard, gameState: gameState)
        let selectedCard = options.max(by: { $0.value < $1.value })?.card ?? hand.first!
        
        knownCards.append(selectedCard)
        return selectedCard
    }
    
    // Enhanced banking strategy for best-of-5 format
    func shouldUseBankedPower(gameState: GameState) -> Bool {
        guard let bankedPower = gameState.enemy.bankedPower,
              !gameState.enemy.isBankedPowerLocked else { return false }
        
        let state = analyzeGameState(gameState)
        let playerScore = gameState.scoreState.playerHandPoints
        let enemyScore = gameState.scoreState.enemyHandPoints
        let duskCardsInHand = gameState.enemy.hand.filter { $0.suit == .dusk }.count
        
        // Must-use situations
        if enemyScore + bankedPower > playerScore { return true }  // Can win hand
        if state.isCritical && bankedPower >= 5 { return true }  // Critical situation with significant power
        if gameState.scoreState.playerRoundsWon == 2 && bankedPower >= 4 { return true }  // Prevent match loss
        
        // Consider using power based on game state
        let baseChance = aggressiveness * (Double(bankedPower) / 10.0)
        let modifiedChance = baseChance * state.roundImportance
        
        // Increase chance if we have few Dusk cards (more likely to lose power)
        if duskCardsInHand <= 1 {
            return Double.random(in: 0...1) < modifiedChance * 1.3
        }
        
        return Double.random(in: 0...1) < modifiedChance
    }
    
    // Helper to track card distributions
    private func analyzeRemainingDeck(_ gameState: GameState) -> (dawn: Int, dusk: Int, night: Int) {
        let knownDawn = knownCards.filter { $0.suit == .dawn }.count
        let knownDusk = knownCards.filter { $0.suit == .dusk }.count
        let knownNight = knownCards.filter { $0.suit == .night }.count
        
        return (
            dawn: 12 - knownDawn,
            dusk: 12 - knownDusk,
            night: 12 - knownNight
        )
    }
}
