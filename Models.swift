//
//  Models.swift
//  Penumbral
//
//  Created by Braxton Smallwood on 1/5/25.
//

import Foundation

enum Suit: String, Comparable {
    case dawn = "Dawn"
    case dusk = "Dusk"
    case night = "Night"
    
    static func < (lhs: Suit, rhs: Suit) -> Bool {
        let order: [Suit] = [.dawn, .dusk, .night]  // Dawn leftmost
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex  // Simple ordering without reversal
    }
}

struct Card {
    let id: String
    let suit: Suit
    let value: Int
}

// Represents the combination of two cards played in sequence
struct CardCombination {
    let firstCard: Card
    let secondCard: Card
    
    // Calculate immediate points from this combination
    func calculateImmediatePoints() -> Int {
            let suits = (firstCard.suit, secondCard.suit)
            switch suits {
            case (.dawn, .dawn):
                // Add both values and double
                return (firstCard.value + secondCard.value) * 2
                
            case (.dusk, .dusk):
                // Dusk+Dusk scores sum
                return firstCard.value + secondCard.value
                
            case (.dawn, _), (_, .dawn):
                // If Dawn is second, double its value
                return suits.1 == .dawn ? secondCard.value * 2 : firstCard.value
                
            case (.night, .night), (.night, .dusk), (.dusk, .night):
                // No immediate points for Night combinations
                return 0
                
            default:
                return 0
            }
        }
    
    // Calculate points to bank from this combination
    func calculateBankedPoints() -> Int {
            let suits = (firstCard.suit, secondCard.suit)
            switch suits {
            case (.night, .night):
                // Bank both values and double
                return (firstCard.value + secondCard.value) * 2
                
            case (.night, _), (_, .night):
                // If Night is second, double its value for banking
                let nightCard = suits.0 == .night ? firstCard : secondCard
                return suits.1 == .night ? nightCard.value * 2 : nightCard.value
                
            default:
                return 0
            }
        }
    
    // Calculate points to cancel from opponent's bank
    func calculateCancelledPoints() -> Int {
            let suits = (firstCard.suit, secondCard.suit)
            switch suits {
            case (.dusk, .dusk):
                // Cancel sum of both values
                return firstCard.value + secondCard.value
                
            case (.dusk, _), (_, .dusk):
                // If Dusk is second, double its cancel value
                let duskCard = suits.0 == .dusk ? firstCard : secondCard
                return suits.1 == .dusk ? duskCard.value * 2 : duskCard.value
                
            default:
                return 0
            }
        }

    // Update the description to reflect new Dusk+Dusk behavior
    func getDescription() -> String {
            let suits = (firstCard.suit, secondCard.suit)
            switch suits {
            case (.dawn, .dawn):
                let baseSum = firstCard.value + secondCard.value
                return "Max Power \(baseSum) x 2: \(baseSum * 2)"
                
            case (.night, .night):
                let baseSum = firstCard.value + secondCard.value
                return "Max Bank \(baseSum) x 2: \(baseSum * 2)"
                
            case (.dusk, .dusk):
                let sum = firstCard.value + secondCard.value
                return "Score \(sum) + Cancel \(sum)"
                
            case (.dawn, .night), (.night, .dawn):
                let isNightSecond = suits.1 == .night
                let dawnCard = suits.0 == .dawn ? firstCard : secondCard
                let nightCard = suits.0 == .night ? firstCard : secondCard
                let powerValue = suits.1 == .dawn ? dawnCard.value * 2 : dawnCard.value
                let bankValue = isNightSecond ? nightCard.value * 2 : nightCard.value
                return "Power \(powerValue) + Bank \(bankValue)"
                
            case (.dawn, .dusk), (.dusk, .dawn):
                let isDuskSecond = suits.1 == .dusk
                let dawnCard = suits.0 == .dawn ? firstCard : secondCard
                let duskCard = suits.0 == .dusk ? firstCard : secondCard
                let powerValue = suits.1 == .dawn ? dawnCard.value * 2 : dawnCard.value
                let cancelValue = isDuskSecond ? duskCard.value * 2 : duskCard.value
                return "Power \(powerValue) + Cancel \(cancelValue)"
                
            case (.night, .dusk), (.dusk, .night):
                let isDuskSecond = suits.1 == .dusk
                let nightCard = suits.0 == .night ? firstCard : secondCard
                let duskCard = suits.0 == .dusk ? firstCard : secondCard
                let bankValue = suits.1 == .night ? nightCard.value * 2 : nightCard.value
                let cancelValue = isDuskSecond ? duskCard.value * 2 : duskCard.value
                return "Bank \(bankValue) + Cancel \(cancelValue)"
                
            default:
                return "Invalid combination"
            }
        }
}

class Player {
    var deck: [Card]
    var hand: [Card]
    var bankedPower: Int?
    var isBankedPowerLocked: Bool
    
    init(deck: [Card]) {
        self.deck = deck
        self.hand = []
        self.bankedPower = nil
        self.isBankedPowerLocked = false
    }
    
    func drawCard() {
        guard !deck.isEmpty else { return }
        let card = deck.removeFirst()
        hand.append(card)
    }
    
    func lockBankedPower() {
        isBankedPowerLocked = true
    }
    
    func unlockBankedPower() {
        isBankedPowerLocked = false
    }
}

struct GameScoreState {
    // Current hand points separated into card points and banked points
    var playerCardPoints = 0
    var enemyCardPoints = 0
    var playerBankedUsedThisHand = 0
    var enemyBankedUsedThisHand = 0
    
    // Track hands won in current round
    var playerHandsWon = 0
    var enemyHandsWon = 0
    
    // Track round wins for match
    var playerRoundsWon = 0
    var enemyRoundsWon = 0
    
    // Track scores for each round
    struct RoundScores {
        var playerHandsWon = 0
        var enemyHandsWon = 0
    }
    var roundScores: [RoundScores] = Array(repeating: RoundScores(), count: 5)
    var currentRound = 0  // 0-based index for current round
    
    // Total points as computed properties
    var playerHandPoints: Int {
        get { return playerCardPoints + playerBankedUsedThisHand }
        set { playerCardPoints = newValue - playerBankedUsedThisHand }
    }
    
    var enemyHandPoints: Int {
        get { return enemyCardPoints + enemyBankedUsedThisHand }
        set { enemyCardPoints = newValue - enemyBankedUsedThisHand }
    }
    
    // Method for updating card points only
    mutating func setCardPoints(points: Int, isPlayer: Bool) {
        if isPlayer {
            playerCardPoints = points
        } else {
            enemyCardPoints = points
        }
    }
    
    // Method for using banked power - only updates banked portion
    mutating func useBankedPower(amount: Int, isPlayer: Bool) {
        if isPlayer {
            playerBankedUsedThisHand = amount
        } else {
            enemyBankedUsedThisHand = amount
        }
    }
    
    mutating func resetHandPoints() {
        playerCardPoints = 0
        enemyCardPoints = 0
        playerBankedUsedThisHand = 0
        enemyBankedUsedThisHand = 0
    }
    
    mutating func finishHand() {
        // Only update scores if the round isn't complete
        if !isRoundComplete {
            if playerHandPoints > enemyHandPoints {
                playerHandsWon += 1
                // Update current round's score
                roundScores[currentRound].playerHandsWon = playerHandsWon
            } else if enemyHandPoints > playerHandPoints {
                enemyHandsWon += 1
                // Update current round's score
                roundScores[currentRound].enemyHandsWon = enemyHandsWon
            }
            
            // Check if this hand completion results in a round win
            if playerHandsWon >= 3 || enemyHandsWon >= 3 {
                if playerHandsWon >= 3 {
                    playerRoundsWon += 1
                } else {
                    enemyRoundsWon += 1
                }
            }
        }
    }
    
    mutating func resetRound() {
        playerHandsWon = 0
        enemyHandsWon = 0
        resetHandPoints()
    }
    
    mutating func finishRound() {
        // Only move to next round if current round is actually complete
        if isRoundComplete {
            currentRound += 1
            playerHandsWon = 0
            enemyHandsWon = 0
            resetHandPoints()
        }
    }
    
    var isRoundComplete: Bool {
        return playerHandsWon >= 3 || enemyHandsWon >= 3
    }
    
    var isMatchComplete: Bool {
        return playerRoundsWon >= 3 || enemyRoundsWon >= 3
    }
}


class GameState {
    var enemyAI: EnemyAI
    var player: Player
    var enemy: Player
    var currentTurn: Int
    var playerFaceUpCard: Card?
    var enemyFaceUpCard: Card?
    var playerSecondCard: Card?
    var enemySecondCard: Card?
    
    // Replace old scoring with new GameScoreState
    var scoreState = GameScoreState()
    
    init() {
        // Create initial decks (1-8 of each suit)
        let playerDeck = GameState.createInitialDeck()
        let enemyDeck = GameState.createInitialDeck()
        
        self.player = Player(deck: playerDeck)
        self.enemy = Player(deck: enemyDeck)
        self.currentTurn = 1
        self.enemyAI = HardAI()
        
        // Initial draw of 10 cards
        for _ in 0..<10 {
            player.drawCard()
            enemy.drawCard()
        }
    }
    
    static func createInitialDeck() -> [Card] {
        var deck: [Card] = []
        for suit in [Suit.night, .dusk, .dawn] {  // Changed to match our correct order
            for value in 1...12 {
                deck.append(Card(id: "\(suit)-\(value)", suit: suit, value: value))
            }
        }
        return deck.shuffled()
    }
    
    // New function to process both combinations at once
    func processRoundCombinations(playerCombo: CardCombination, enemyCombo: CardCombination) {
        let playerImmediate = playerCombo.calculateImmediatePoints()
        let playerBanked = playerCombo.calculateBankedPoints()
        let playerCancelled = playerCombo.calculateCancelledPoints()
        
        let enemyImmediate = enemyCombo.calculateImmediatePoints()
        let enemyBanked = enemyCombo.calculateBankedPoints()
        let enemyCancelled = enemyCombo.calculateCancelledPoints()
        
        // Set immediate points using setCardPoints
        if playerImmediate > 0 {
            scoreState.setCardPoints(points: playerImmediate, isPlayer: true)
        }
        if enemyImmediate > 0 {
            scoreState.setCardPoints(points: enemyImmediate, isPlayer: false)
        }
        
        // Apply banking
        if playerBanked > 0 {
            player.bankedPower = (player.bankedPower ?? 0) + playerBanked
        }
        if enemyBanked > 0 {
            enemy.bankedPower = (enemy.bankedPower ?? 0) + enemyBanked
        }
        
        // Apply cancellations
        if playerCancelled > 0 {
            enemy.bankedPower = max(0, (enemy.bankedPower ?? 0) - playerCancelled)
        }
        if enemyCancelled > 0 {
            player.bankedPower = max(0, (player.bankedPower ?? 0) - enemyCancelled)
        }
        
        if playerSecondCard != nil && enemySecondCard != nil {
            scoreState.finishHand()
            if scoreState.isRoundComplete {
                scoreState.finishRound()
            }
        }
    }
    
    // In GameState class:
    func processFirstCards(playerCard: Card) {
        playerFaceUpCard = playerCard
        enemyFaceUpCard = enemyAI.selectFirstCard(from: enemy.hand, gameState: self)
        
        // Calculate immediate points from first cards
        if playerCard.suit == .dawn {
            scoreState.setCardPoints(points: playerCard.value, isPlayer: true)
        }
        if enemyFaceUpCard?.suit == .dawn {
            scoreState.setCardPoints(points: enemyFaceUpCard!.value, isPlayer: false)
        }
        
        // Handle Dusk locking mechanics
        if playerCard.suit == .dusk {
            enemy.lockBankedPower()
        }
        if enemyFaceUpCard?.suit == .dusk {
            player.lockBankedPower()
        }
    }
    
    func processSecondCards(playerCard: Card) {
        playerSecondCard = playerCard
        enemySecondCard = enemyAI.selectSecondCard(
            hand: enemy.hand,
            firstCard: enemyFaceUpCard!,
            gameState: self
        )
        
        let playerCombo = CardCombination(firstCard: playerFaceUpCard!, secondCard: playerSecondCard!)
        let enemyCombo = CardCombination(firstCard: enemyFaceUpCard!, secondCard: enemySecondCard!)
        
        processRoundCombinations(playerCombo: playerCombo, enemyCombo: enemyCombo)
    }
    
    func processCardCombination(player: Player, opponent: Player, combination: CardCombination) {
        // Calculate immediate points
        let immediatePoints = combination.calculateImmediatePoints()
        
        // Add to existing card points instead of replacing
        if player === self.player {
            scoreState.playerCardPoints += immediatePoints
        } else {
            scoreState.enemyCardPoints += immediatePoints
        }
        
        // Rest of the banking and cancellation logic remains the same
        let bankedPoints = combination.calculateBankedPoints()
        if bankedPoints > 0 {
            player.bankedPower = (player.bankedPower ?? 0) + bankedPoints
        }
        
        let cancelledPoints = combination.calculateCancelledPoints()
        if cancelledPoints > 0 && opponent.bankedPower != nil {
            opponent.bankedPower = max(0, opponent.bankedPower! - cancelledPoints)
        }
        
        // Reset locks at end of combination
        player.unlockBankedPower()
        opponent.unlockBankedPower()
        
        // Check if this completes the hand
        if playerSecondCard != nil && enemySecondCard != nil {
            scoreState.finishHand()
            
            if scoreState.isRoundComplete {
                finishRound()
            }
        }
    }
    
    // Determine round winner and update match score
        private func finishRound() {
            // The hand winner is already determined in GameScoreState.finishHand()
            // Here we just need to process the round completion
            scoreState.finishRound()
            
            // Clear face-up cards and second cards
            playerFaceUpCard = nil
            enemyFaceUpCard = nil
            playerSecondCard = nil
            enemySecondCard = nil
            
            // Draw new cards if needed
            while player.hand.count < 10 && !player.deck.isEmpty {
                player.drawCard()
            }
            while enemy.hand.count < 10 && !enemy.deck.isEmpty {
                enemy.drawCard()
            }
            
            // Reset banked power locks
            player.isBankedPowerLocked = false
            enemy.isBankedPowerLocked = false
        }
    }
