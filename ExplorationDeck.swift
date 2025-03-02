//
//  ExplorationDeck.swift
//  CardLoop
//
//  Created by Braxton Smallwood on 3/1/25.
//

import Foundation

// Exploration Deck Manager
class ExplorationDeck {
    private var drawPile: [ExplorationCard] = []
    private var discardPile: [ExplorationCard] = []
    private(set) var hand: [ExplorationCard] = []
    
    let handSize: Int
    
    init(cards: [ExplorationCard], handSize: Int = 5) {
        self.drawPile = cards.shuffled()
        self.handSize = handSize
        drawInitialHand()
    }
    
    // Draw initial hand
    private func drawInitialHand() {
        for _ in 0..<min(handSize, drawPile.count) {
            hand.append(drawPile.removeFirst())
        }
    }
    
    // Draw a new card
    func drawCard() {
        guard !drawPile.isEmpty && hand.count < handSize else { return }
        
        // If draw pile is empty, shuffle discard pile into draw pile
        if drawPile.isEmpty {
            drawPile = discardPile.shuffled()
            discardPile.removeAll()
        }
        
        if !drawPile.isEmpty {
            hand.append(drawPile.removeFirst())
        }
    }
    
    // Play a card from hand
    func playCard(at index: Int) -> ExplorationCard? {
        guard index >= 0 && index < hand.count else { return nil }
        
        let card = hand.remove(at: index)
        discardPile.append(card)
        
        // Draw a new card if possible
        drawCard()
        
        return card
    }
    
    // Discard a card from hand
    func discardCard(at index: Int) {
        guard index >= 0 && index < hand.count else { return }
        
        let card = hand.remove(at: index)
        discardPile.append(card)
        
        // Draw a new card if possible
        drawCard()
    }
    
    // Get a preview of the top card in the draw pile
    func peekTopCard() -> ExplorationCard? {
        return drawPile.first
    }
    
    // Shuffle the draw pile
    func shuffleDrawPile() {
        drawPile.shuffle()
    }
    
    // Shuffle the discard pile into the draw pile
    func reshuffleDiscard() {
        drawPile.append(contentsOf: discardPile.shuffled())
        discardPile.removeAll()
    }
}
