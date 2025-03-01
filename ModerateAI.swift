//
//  ModerateAI.swift
//  Penumbral
//
//  Created by Braxton Smallwood on 1/8/25.
//

import Foundation

class ModerateAI: EnemyAI {
    // Personality traits
    var bankingProbability: Double { return 0.3 }  // 30% base chance to bank
    var aggressiveness: Double { return 0.5 }      // Moderate aggression
    var prefersHighCards: Bool { return true }
    
    // Helper for evaluating game situation
    private func evaluateGameState(_ gameState: GameState) -> (isCritical: Bool, shouldBeAggressive: Bool) {
        let playerWins = gameState.scoreState.playerRoundsWon
        let enemyWins = gameState.scoreState.enemyRoundsWon
        let playerRoundScore = gameState.scoreState.playerHandPoints
        let enemyRoundScore = gameState.scoreState.enemyHandPoints
        let playerBankedPower = gameState.player.bankedPower ?? 0
        
        // Critical situations:
        // 1. Player is one win away from victory
        // 2. Player has significant banked power
        let isCritical = playerWins == 2 || playerBankedPower > 10
        
        // Be aggressive if:
        // 1. Enemy is behind in wins
        // 2. Enemy is losing current round significantly
        // 3. Player has banked power that could be threatening
        let isSignificantlyBehind = enemyRoundScore + 5 < playerRoundScore
        let shouldBeAggressive = enemyWins < playerWins ||
                               isSignificantlyBehind ||
                               playerBankedPower > 5
        
        return (isCritical, shouldBeAggressive)
    }
    
    private func evaluateFirstCardOptions(hand: [Card], gameState: GameState) -> [(card: Card, value: Double)] {
        let (isCritical, shouldBeAggressive) = evaluateGameState(gameState)
        let playerBankedPower = gameState.player.bankedPower ?? 0
        let hasDuskPair = hand.filter { $0.suit == .dusk }.count >= 2
        let hasNightPair = hand.filter { $0.suit == .night }.count >= 2
        
        return hand.map { card in
            var value = Double(card.value) // Base value
            
            switch card.suit {
            case .dawn:
                // Dawn is good for aggressive plays
                if shouldBeAggressive {
                    value *= 1.5
                }
                
            case .night:
                // Night is now more valuable with double banking potential
                if hasNightPair {
                    value *= 1.5  // Increased from 1.3 for double banking potential
                }
                if !shouldBeAggressive {
                    value *= 1.3
                }
                // Less valuable if opponent has no banked power
                if playerBankedPower == 0 {
                    value *= 0.7
                }
                
            case .dusk:
                // Updated Dusk evaluation for new mechanics
                if playerBankedPower > 0 {
                    // More valuable to lock opponent's power when they have some
                    value *= 1.3
                    
                    // Even more valuable if we have another Dusk to follow up
                    if hasDuskPair {
                        value *= 1.4
                    }
                } else if hasDuskPair {
                    // Still valuable for scoring if we can play double Dusk
                    value *= 1.2
                } else {
                    value *= 0.7 // Less valuable if no power to lock and no second Dusk
                }
            }
            
            // Add some randomness
            value *= Double.random(in: 0.9...1.1)
            
            return (card, value)
        }
    }
    
    private func evaluateCardCombination(_ combination: CardCombination, gameState: GameState) -> Double {
        let immediatePoints = Double(combination.calculateImmediatePoints())
        let bankedPoints = Double(combination.calculateBankedPoints())
        let cancelledPoints = Double(combination.calculateCancelledPoints())
        let playerBankedPower = Double(gameState.player.bankedPower ?? 0)
        
        let (isCritical, shouldBeAggressive) = evaluateGameState(gameState)
        
        var value = 0.0
        
        // Value immediate points more highly
        value += immediatePoints * 1.2
        
        // Updated banking evaluation with new doubled Night+Night mechanic
        if combination.firstCard.suit == .night && combination.secondCard.suit == .night {
            // Night+Night is now more valuable since it doubles
            if shouldBeAggressive {
                value += bankedPoints * 0.8  // Increased from 0.5
            } else {
                value += bankedPoints * 1.8  // Increased from 1.5
            }
        } else {
            // Regular banking value for other combinations
            if shouldBeAggressive {
                value += bankedPoints * 0.5
            } else {
                value += bankedPoints * 1.5
            }
        }
        
        // Updated valuation for Dusk combinations
        if combination.firstCard.suit == .dusk && combination.secondCard.suit == .dusk {
            // Double Dusk is now more valuable as it both scores and cancels
            value += Double(combination.firstCard.value + combination.secondCard.value) * 1.3
            if playerBankedPower > 0 {
                value += cancelledPoints * 1.2
            }
        } else if cancelledPoints > 0 && playerBankedPower > 0 {
            // Single Dusk cancellation
            value += cancelledPoints * (1.0 + playerBankedPower / 10.0)
        }
        
        if isCritical {
            value *= 1.5
        }
        
        value *= Double.random(in: 0.9...1.1)
        
        return value
    }
    
    func selectFirstCard(from hand: [Card], gameState: GameState) -> Card {
        let options = evaluateFirstCardOptions(hand: hand, gameState: gameState)
        let bestOption = options.max(by: { $0.value < $1.value })
        return bestOption?.card ?? hand.first!
    }
    
    func selectSecondCard(hand: [Card], firstCard: Card, gameState: GameState) -> Card {
        var bestCombination: (card: Card, value: Double)? = nil
        
        for card in hand {
            let combination = CardCombination(firstCard: firstCard, secondCard: card)
            let value = evaluateCardCombination(combination, gameState: gameState)
            
            if bestCombination == nil || value > bestCombination!.value {
                bestCombination = (card, value)
            }
        }
        
        return bestCombination?.card ?? hand.first!
    }
    
    func shouldUseBankedPower(gameState: GameState) -> Bool {
        guard let bankedPower = gameState.enemy.bankedPower,
              !gameState.enemy.isBankedPowerLocked else { return false }
        
        let playerScore = gameState.scoreState.playerHandPoints
        let enemyScore = gameState.scoreState.enemyHandPoints
        let playerFirstCard = gameState.playerFaceUpCard
        
        // If player has played a Dusk card, we can't use power
        if let firstCard = playerFirstCard, firstCard.suit == .dusk {
            return false
        }
        
        // Check if this is before our first card
        let isBeforeFirstCard = playerFirstCard == nil
        
        // Count Night cards in hand for banking potential
        let nightCardsInHand = gameState.enemy.hand.filter { $0.suit == .night }.count
        
        // Critical situations that should trigger power use:
        
        // 1. Can win the round with banked power
        if enemyScore + bankedPower > playerScore {
            return true
        }
        
        // 2. Player is close to winning match
        if gameState.scoreState.playerRoundsWon == 2 {
            return bankedPower >= 4  // Use significant banked power to prevent loss
        }
        
        // 3. Significantly behind in current round
        if playerScore > enemyScore + 5 {
            return bankedPower >= 6  // Use large banked power to catch up
        }
        
        // Before first card considerations
        if isBeforeFirstCard {
            // Use power if we have a lot banked and few Night cards
            if bankedPower >= 8 && nightCardsInHand <= 1 {
                return true
            }
            
            // Behind in rounds with significant power
            if gameState.scoreState.playerRoundsWon > gameState.scoreState.enemyRoundsWon && bankedPower >= 6 {
                return true
            }
        }
        // Between cards considerations
        else {
            // Consider using power before opponent's second card
            if bankedPower >= 5 {
                // Higher chance to use power if we're behind or have a lot banked
                let useChance = aggressiveness * Double(bankedPower) / 10.0
                if gameState.scoreState.playerRoundsWon > gameState.scoreState.enemyRoundsWon {
                    return Double.random(in: 0...1) < useChance * 1.3  // More likely if behind in rounds
                }
                return Double.random(in: 0...1) < useChance
            }
        }
        
        // Base chance based on aggressiveness and power amount
        let baseChance = aggressiveness * Double(bankedPower) / 10.0
        return Double.random(in: 0...1) < baseChance
    }
    
    func shouldUseInitialBankedPower(_ gameState: GameState) -> Bool {
            guard let bankedPower = gameState.enemy.bankedPower,
                  !gameState.enemy.isBankedPowerLocked else { return false }
            
            let playerScore = gameState.scoreState.playerHandPoints
            let enemyScore = gameState.scoreState.enemyHandPoints
            
            // Count remaining Night cards in hand
            let nightCardsInHand = gameState.enemy.hand.filter { $0.suit == .night }.count
            
            // Critical situations to use power immediately:
            
            // 1. High amount banked and few Night cards left (high risk of losing it)
            if bankedPower >= 8 && nightCardsInHand <= 1 {
                return true
            }
            
            // 2. Behind in rounds and significant power banked
            if gameState.scoreState.playerRoundsWon > gameState.scoreState.enemyRoundsWon && bankedPower >= 6 {
                return true
            }
            
            // 3. Currently behind in round score significantly
            if playerScore > enemyScore + 8 && bankedPower >= 5 {
                return true
            }
            
            // 4. Match point for opponent
            if gameState.scoreState.playerRoundsWon == 2 && bankedPower >= 4 {
                return true
            }
            
            return false
        }
}
