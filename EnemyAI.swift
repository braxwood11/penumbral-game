//
//  EnemyAI.swift
//  Penumbral
//
//  Created by Braxton Smallwood on 1/8/25.
//

import Foundation

protocol EnemyAI {
    func selectFirstCard(from hand: [Card], gameState: GameState) -> Card
    func selectSecondCard(hand: [Card], firstCard: Card, gameState: GameState) -> Card
    func shouldUseBankedPower(gameState: GameState) -> Bool
    
    var bankingProbability: Double { get }
    var aggressiveness: Double { get }
    var prefersHighCards: Bool { get }
}

// Default implementation
extension EnemyAI {
    var bankingProbability: Double { return 0.3 }
    var aggressiveness: Double { return 0.5 }
    var prefersHighCards: Bool { return true }
    
    // Default implementation for new function
    func shouldUseInitialBankedPower(_ gameState: GameState) -> Bool {
        return false
    }
}
