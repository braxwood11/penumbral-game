//
//  ExplorationViews.swift
//  CardLoop
//
//  Created by Braxton Smallwood on 3/1/25.
//

import SpriteKit

// Delegate protocol for hand interaction
protocol ExplorationHandDelegate: AnyObject {
    func didSelectCard(at index: Int)
    func didDeselectCard()
}

// Visual representation of an exploration card
class ExplorationCardView: SKNode {
    private let card: ExplorationCard
    private var background: SKShapeNode!
    private var selectionGlow: SKShapeNode!
    
    init(card: ExplorationCard) {
        self.card = card
        super.init()
        setupCardView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCardView() {
        // Reduce card dimensions from 120x170 to 100x140
        let cardWidth: CGFloat = 100  // Reduced from 120
        let cardHeight: CGFloat = 140  // Reduced from 170
        
        // Card background
        background = SKShapeNode(rectOf: CGSize(width: cardWidth, height: cardHeight), cornerRadius: 8)
        
        // Set card color based on valid realm
        if card.validRealms.contains(.dawn) {
            background.fillColor = Realm.dawn.color.withAlphaComponent(0.8)
        } else if card.validRealms.contains(.dusk) {
            background.fillColor = Realm.dusk.color.withAlphaComponent(0.8)
        } else if card.validRealms.contains(.night) {
            background.fillColor = Realm.night.color.withAlphaComponent(0.8)
        } else {
            background.fillColor = SKColor.lightGray.withAlphaComponent(0.8)
        }
        
        // Add rarity border
        background.strokeColor = card.rarity.color
        background.lineWidth = card.rarity == .common ? 1.5 : 2.5  // Slightly reduced from 2:3
        addChild(background)
        
        // Card name - smaller font
        let nameLabel = SKLabelNode(fontNamed: "Copperplate")
        nameLabel.text = card.name
        nameLabel.fontSize = 14  // Reduced from 16
        nameLabel.fontColor = .black
        nameLabel.position = CGPoint(x: 0, y: cardHeight/2 - 20)  // Adjusted position
        addChild(nameLabel)
        
        // Card type icon - smaller size
        let iconNode = SKSpriteNode(texture: getIconTexture(for: card.cardType))
        iconNode.size = CGSize(width: 32, height: 32)  // Reduced from 40x40
        iconNode.position = CGPoint(x: 0, y: 15)  // Adjusted position
        addChild(iconNode)
        
        // Card description (multi-line) - smaller font
        let description = SKLabelNode(fontNamed: "Copperplate")
        description.text = card.description
        description.fontSize = 10  // Reduced from 12
        description.fontColor = .black
        description.preferredMaxLayoutWidth = cardWidth - 15  // Adjusted for smaller width
        description.numberOfLines = 0
        description.verticalAlignmentMode = .center
        description.position = CGPoint(x: 0, y: -35)  // Adjusted position
        addChild(description)
        
        // Realm icons (showing where card can be used) - smaller size
        let realmIconsNode = SKNode()
        let realmIconSize: CGFloat = 12  // Reduced from 15
        let totalWidth = CGFloat(card.validRealms.count) * realmIconSize + CGFloat(max(0, card.validRealms.count - 1)) * 4  // Reduced spacing from 5 to 4
        var currentX = -totalWidth / 2 + realmIconSize / 2
        
        for realm in card.validRealms {
            let realmIcon = SKShapeNode(circleOfRadius: realmIconSize/2)
            realmIcon.fillColor = realm.color
            realmIcon.strokeColor = .white
            realmIcon.lineWidth = 1
            realmIcon.position = CGPoint(x: currentX, y: -cardHeight/2 + 12)  // Adjusted position
            realmIconsNode.addChild(realmIcon)
            
            currentX += realmIconSize + 4  // Reduced spacing from 5 to 4
        }
        
        addChild(realmIconsNode)
        
        // Add invisible selection glow (will be shown when selected)
        selectionGlow = SKShapeNode(rectOf: CGSize(width: cardWidth + 8, height: cardHeight + 8), cornerRadius: 10)  // Reduced padding from 10 to 8
        selectionGlow.fillColor = .clear
        selectionGlow.strokeColor = .white
        selectionGlow.lineWidth = 2
        selectionGlow.alpha = 0
        addChild(selectionGlow)
    }
    
    // Get appropriate icon for the card type
    private func getIconTexture(for cardType: ExplorationCardType) -> SKTexture {
        let iconName: String
        switch cardType {
        case .path: iconName = "path_icon"
        case .jump: iconName = "jump_icon"
        case .reveal: iconName = "reveal_icon"
        case .phase: iconName = "phase_icon"
        case .special: iconName = "special_icon"
        }
        
        return ImageUtilities.getTexture(for: iconName)
    }
    
    // Set card selection state
    func setSelected(_ selected: Bool) {
        if selected {
            // Show selection glow
            selectionGlow.alpha = 0.8
            
            // Add pulsing animation
            selectionGlow.removeAllActions()
            selectionGlow.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.fadeAlpha(to: 0.4, duration: 0.8),
                SKAction.fadeAlpha(to: 0.8, duration: 0.8)
            ])))
            
            // Slightly enlarge the card
            run(SKAction.scale(to: 1.1, duration: 0.2))
            zPosition = 10 // Bring to front
        } else {
            // Hide selection glow
            selectionGlow.removeAllActions()
            selectionGlow.run(SKAction.fadeOut(withDuration: 0.2))
            
            // Return to normal size
            run(SKAction.scale(to: 1.0, duration: 0.2))
            zPosition = 0
        }
    }
}

class ExplorationHandView: SKNode {
    private var cards: [ExplorationCardView] = []
    private var cardSpacing: CGFloat = 12
    private var selectedCardIndex: Int? = nil
    private var targetingMode = false
    
    weak var delegate: ExplorationHandDelegate?
    
    // Initialize with a set of exploration cards
    func updateWithCards(_ explorationCards: [ExplorationCard]) {
        // Remove existing card views
        for card in cards {
            card.removeFromParent()
        }
        cards.removeAll()
        
        // Create new card views
        for (index, card) in explorationCards.enumerated() {
            let cardView = ExplorationCardView(card: card)
            cardView.position = cardPosition(for: index, in: explorationCards.count)
            cardView.name = "card_\(index)"
            addChild(cardView)
            cards.append(cardView)
        }
    }
    
    // Calculate position for a card in the hand
    private func cardPosition(for index: Int, in total: Int) -> CGPoint {
        // Calculate the total width needed for all cards
        let cardWidth: CGFloat = 100  // Updated from 120
        let totalWidth = cardWidth * CGFloat(total) + cardSpacing * CGFloat(total - 1)
        let startX = -totalWidth / 2 + cardWidth / 2
        
        return CGPoint(x: startX + CGFloat(index) * (cardWidth + cardSpacing), y: 0)
    }
    
    // Handle touch on a card
    func handleTouch(at location: CGPoint) -> Bool {
        // If in targeting mode, don't allow selecting a different card
        if targetingMode { return false }
        
        // Check if a card was touched
        for (index, cardView) in cards.enumerated() {
            if cardView.contains(location) {
                selectCard(at: index)
                return true
            }
        }
        
        return false
    }
    
    // Select a card
    private func selectCard(at index: Int) {
        // Deselect previously selected card
        if let prevIndex = selectedCardIndex, prevIndex < cards.count {
            cards[prevIndex].setSelected(false)
        }
        
        // If tapping the same card, deselect it
        if selectedCardIndex == index {
            selectedCardIndex = nil
            delegate?.didDeselectCard()
            return
        }
        
        // Select the new card
        selectedCardIndex = index
        cards[index].setSelected(true)
        
        // Notify delegate
        delegate?.didSelectCard(at: index)
    }
    
    // Enter targeting mode (waiting for target selection)
    func enterTargetingMode() {
        targetingMode = true
        
        // Dim all cards except the selected one
        for (index, card) in cards.enumerated() {
            if index != selectedCardIndex {
                card.run(SKAction.fadeAlpha(to: 0.5, duration: 0.3))
            }
        }
    }
    
    // Exit targeting mode
    func exitTargetingMode() {
        targetingMode = false
        
        // Restore all cards
        for card in cards {
            card.run(SKAction.fadeAlpha(to: 1.0, duration: 0.3))
        }
        
        // Deselect the card
        if let index = selectedCardIndex, index < cards.count {
            cards[index].setSelected(false)
            selectedCardIndex = nil
        }
    }
    
    // Get the currently selected card index
    func getSelectedCardIndex() -> Int? {
        return selectedCardIndex
    }
}
