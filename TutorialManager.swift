//
//  TutorialManager.swift
//  Penumbral
//
//  Created by Braxton Smallwood on 3/1/25.
//

import SpriteKit

enum TutorialStep: Int, CaseIterable {
    case welcome
    case objective
    case cardSuits
    case dawnCards
    case nightCards
    case duskCards
    case gameFlow
    case firstCard
    case secondCard
    case combinations
    case crossSuitCombos
    case banking
    case winning
    case tips
    case tapHelp
    case completion
}

enum TutorialAction {
    case selectFirstCard
    case selectSecondCard
    case tapNextRound
    case useBankedPower
    case tapHelp
}

class TutorialManager {
    private weak var gameScene: GameScene?
    private var currentStep = TutorialStep.welcome
    private var messageNode: SKNode?
    private var highlightNode: SKNode?
    private var overlay: SKNode?
    
    var isActive = false
    
    init(gameScene: GameScene) {
        self.gameScene = gameScene
    }
    
    // MARK: - Public Methods
    
    func startTutorial() {
        guard let gameScene = gameScene, !isActive else { return }
        
        isActive = true
        
        // Create semi-transparent overlay
        createOverlay()
        
        // Show first step
        showStep(currentStep)
    }
    
    func endTutorial() {
        isActive = false
        
        UserDefaults.standard.set(true, forKey: "tutorialCompleted")
        
        clearUI()
    }
    
    func handleTap(at location: CGPoint) -> Bool {
        guard isActive else { return false }
        
        // Continue to next step on taps unless waiting for specific action
        if !isWaitingForAction(currentStep) {
            advanceToNextStep()
            return true
        }
        
        return false // Allow the game to handle action taps
    }
    
    func handleAction(_ action: TutorialAction) {
        guard isActive else { return }
        
        // Check if this is the action we're waiting for
        if isWaitingForAction(currentStep) && isExpectedAction(currentStep, action: action) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.advanceToNextStep()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func advanceToNextStep() {
        // Get the next step
        let allSteps = TutorialStep.allCases
        if let currentIndex = allSteps.firstIndex(of: currentStep),
           currentIndex < allSteps.count - 1 {
            
            currentStep = allSteps[currentIndex + 1]
            showStep(currentStep)
        } else {
            // End of tutorial
            endTutorial()
        }
    }
    
    private func showStep(_ step: TutorialStep) {
        // Clear previous step UI
        clearStepUI()
        
        // Show appropriate message and highlight for this step
        let message = getMessageForStep(step)
        showMessage(message)
        
        // Create highlight based on step
        createHighlightForStep(step)
    }
    
    private func isWaitingForAction(_ step: TutorialStep) -> Bool {
        switch step {
        case .firstCard, .secondCard, .tapHelp:
            return true
        // Remove .banking from here since we're not waiting for actual power use
        default:
            return false
        }
    }
    
    private func isExpectedAction(_ step: TutorialStep, action: TutorialAction) -> Bool {
        switch (step, action) {
        case (.firstCard, .selectFirstCard),
             (.secondCard, .selectSecondCard),
             (.tapHelp, .tapHelp):
             // Remove the .banking case
            return true
        default:
            return false
        }
    }
    
    // MARK: - UI Methods
    
    private func createOverlay() {
        guard let gameScene = gameScene else { return }
        
        let node = SKNode()
        let bg = SKShapeNode(rect: CGRect(x: 0, y: 0, width: gameScene.size.width, height: gameScene.size.height))
        bg.fillColor = .black
        bg.alpha = 0.1
        bg.strokeColor = .clear
        node.addChild(bg)
        node.zPosition = 900
        
        gameScene.addChild(node)
        overlay = node
    }
    
    // Add this method to TutorialManager to help with dynamic positioning
    private func getMessageBoxPosition(for step: TutorialStep, boxHeight: CGFloat) -> CGPoint {
        guard let gameScene = gameScene else { return .zero }
        
        // Default position - just below score table
        let defaultY = gameScene.size.height - 225 - boxHeight/2
        
        // Adjust position based on step context
        switch step {
        case .firstCard, .secondCard:
            // For card selection steps, position higher to not obstruct cards
            return CGPoint(x: gameScene.size.width/2, y: gameScene.size.height - 180)
            
        case .combinations, .crossSuitCombos:
            // When discussing combinations, position higher to show examples
            return CGPoint(x: gameScene.size.width/2, y: gameScene.size.height - 180)
            
        case .banking:
            // Position above the bank button
            return CGPoint(x: gameScene.size.width/2, y: gameScene.size.height/2 + 50)
            
        default:
            // Default positioning
            return CGPoint(x: gameScene.size.width/2, y: defaultY)
        }
    }

    // Update the showMessage method to use dynamic positioning
    private func showMessage(_ message: String) {
        guard let gameScene = gameScene else { return }
        
        let node = SKNode()
        node.zPosition = 1000
        
        // Background with rounded corners
        let padding: CGFloat = 20
        let maxWidth = gameScene.size.width - 80
        
        // Create temporary text node to measure
        let tempLabel = SKLabelNode(fontNamed: "Copperplate")
        tempLabel.preferredMaxLayoutWidth = maxWidth - (padding * 2)
        tempLabel.numberOfLines = 0
        tempLabel.text = message
        tempLabel.fontSize = 20
        
        let textHeight = tempLabel.calculateAccumulatedFrame().height
        
        // Add extra space for the "tap to continue" text
        let tapIndicatorHeight: CGFloat = 25
        let boxHeight = max(textHeight + (padding * 2) + tapIndicatorHeight, 120) // Minimum height with tap indicator
        
        let background = SKShapeNode(rectOf: CGSize(width: maxWidth, height: boxHeight), cornerRadius: 10)
        background.fillColor = SKColor(red: 0x4A/255.0, green: 0x52/255.0, blue: 0x74/255.0, alpha: 0.95)
        background.strokeColor = .white
        background.lineWidth = 2
        node.addChild(background)
        
        // Text with proper wrapping - position slightly higher to make room for tap indicator
        let label = SKLabelNode(fontNamed: "Copperplate")
        label.preferredMaxLayoutWidth = maxWidth - (padding * 2)
        label.numberOfLines = 0
        label.text = message
        label.fontSize = 20
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        // Position text slightly higher in the box to make room for tap indicator
        label.position = CGPoint(x: 0, y: tapIndicatorHeight/2)
        node.addChild(label)
        
        // "Tap to continue" indicator - positioned at the bottom with clear separation
        let tapIndicator = SKLabelNode(fontNamed: "Copperplate")
        tapIndicator.text = "Tap to continue"
        tapIndicator.fontSize = 16
        tapIndicator.fontColor = .white.withAlphaComponent(0.7)
        // Place tap indicator at the bottom with clear separation
        tapIndicator.position = CGPoint(x: 0, y: -(boxHeight/2 - tapIndicatorHeight/2))
        tapIndicator.verticalAlignmentMode = .center
        node.addChild(tapIndicator)
        
        // Add a subtle divider line above the tap indicator
        let lineWidth = maxWidth - 40
        let divider = SKShapeNode(rectOf: CGSize(width: lineWidth, height: 1))
        divider.fillColor = .white.withAlphaComponent(0.3)
        divider.strokeColor = .clear
        divider.position = CGPoint(x: 0, y: -(boxHeight/2 - tapIndicatorHeight))
        node.addChild(divider)
        
        // Fade animation for tap indicator
        tapIndicator.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.8),
            SKAction.fadeAlpha(to: 0.7, duration: 0.8)
        ])))
        
        // Use dynamic positioning based on current step
        node.position = getMessageBoxPosition(for: currentStep, boxHeight: boxHeight)
        node.alpha = 0
        
        gameScene.addChild(node)
        node.run(SKAction.fadeIn(withDuration: 0.3))
        
        messageNode = node
    }
    
    private func createHighlightForStep(_ step: TutorialStep) {
        guard let gameScene = gameScene else { return }
        
        let highlight = SKNode()
        highlight.zPosition = 950
        
        switch step {
        case .objective:
            if let scoreTable = gameScene.childNode(withName: "//scoreTable") {
                let frame = scoreTable.calculateAccumulatedFrame()
                let glow = createGlowRect(around: frame, color: .yellow)
                highlight.addChild(glow)
            }
            
        case .dawnCards:
            highlightCardsOfSuit(.dawn)
            
        case .nightCards:
            highlightCardsOfSuit(.night)
            
        case .duskCards:
            highlightCardsOfSuit(.dusk)
            
        case .banking:
            if let powerButton = gameScene.childNode(withName: "usePowerButton") {
                let frame = powerButton.calculateAccumulatedFrame()
                let glow = createGlowRect(around: frame, color: .blue)
                highlight.addChild(glow)
            }
            
        case .tapHelp:
            if let helpButton = gameScene.childNode(withName: "helpButton") {
                let frame = helpButton.calculateAccumulatedFrame()
                let glow = createGlowRect(around: frame, color: .yellow)
                highlight.addChild(glow)
            }
            
        case .crossSuitCombos:
            // Optional: highlight cards of different suits, or just let the text explain
            let differentSuitCards = highlightCrossSuitExample()
            if let cards = differentSuitCards {
                highlight.addChild(cards)
            }
            
        default:
            return // No highlight needed
        }
        
        if !highlight.children.isEmpty {
            gameScene.addChild(highlight)
            highlightNode = highlight
        }
    }

    
    private func setupBankingStep() {
        guard let gameScene = gameScene else { return }
        
        // Highlight the banking button
        if let powerButton = gameScene.childNode(withName: "usePowerButton") {
            let frame = powerButton.calculateAccumulatedFrame()
            let highlight = SKNode()
            highlight.zPosition = 950
            
            let glow = createGlowRect(around: frame, color: .blue)
            highlight.addChild(glow)
            
            gameScene.addChild(highlight)
            highlightNode = highlight
        }
    }
    
    // Improved methods for highlighting cards

    private func highlightCardsOfSuit(_ suit: Suit) {
        guard let gameScene = gameScene else { return }
        
        let highlightNode = SKNode()
        highlightNode.zPosition = 950
        
        // Find all cards of the given suit in player's hand
        for node in gameScene.children {
            if let cardNode = node as? CardNode, cardNode.card.suit == suit {
                // Create a highlight that matches the card's exact position, size, and rotation
                let cardHighlight = createCardHighlight(for: cardNode, color: CardNode.getFontColor(for: suit))
                highlightNode.addChild(cardHighlight)
            }
        }
        
        if !highlightNode.children.isEmpty {
            gameScene.addChild(highlightNode)
            self.highlightNode = highlightNode
        }
    }

    private func createCardHighlight(for cardNode: CardNode, color: SKColor) -> SKNode {
        // Create a container node to match the card's position and rotation
        let container = SKNode()
        container.position = cardNode.position
        container.zRotation = cardNode.zRotation
        
        // Get the card's actual size
        let cardSize = cardNode.size
        
        // Create a shape that matches the card's dimensions
        let highlight = SKShapeNode(rectOf: CGSize(
            width: cardSize.width + 10,
            height: cardSize.height + 10
        ), cornerRadius: 8)
        
        highlight.fillColor = .clear
        highlight.strokeColor = color
        highlight.lineWidth = 3
        highlight.alpha = 0.8
        
        // Add to container
        container.addChild(highlight)
        
        // Pulsing animation
        highlight.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.4, duration: 0.8),
            SKAction.fadeAlpha(to: 0.8, duration: 0.8)
        ])))
        
        return container
    }

    // For highlighting card nodes by filter
    private func highlightNodesByFilter(_ filter: (SKNode) -> Bool) {
        guard let gameScene = gameScene else { return }
        
        // Container for multiple highlights
        let highlightContainer = SKNode()
        highlightContainer.zPosition = 950
        
        // Find all nodes matching the filter
        for node in gameScene.children {
            if filter(node), let cardNode = node as? CardNode {
                let cardHighlight = createCardHighlight(for: cardNode, color: CardNode.getFontColor(for: cardNode.card.suit))
                highlightContainer.addChild(cardHighlight)
            }
        }
        
        if !highlightContainer.children.isEmpty {
            gameScene.addChild(highlightContainer)
            highlightNode = highlightContainer
        }
    }

    // Optional: For highlighting cross-suit combinations
    private func highlightCrossSuitExample() -> SKNode? {
        guard let gameScene = gameScene else { return nil }
        
        let container = SKNode()
        
        // Find one Dawn and one Night card to highlight as an example
        var dawnCard: CardNode? = nil
        var nightCard: CardNode? = nil
        
        for child in gameScene.children {
            if let cardNode = child as? CardNode {
                if cardNode.card.suit == .dawn && dawnCard == nil {
                    dawnCard = cardNode
                } else if cardNode.card.suit == .night && nightCard == nil {
                    nightCard = cardNode
                }
                
                if dawnCard != nil && nightCard != nil {
                    break
                }
            }
        }
        
        // Highlight both cards if found
        if let dawn = dawnCard {
            let highlight = createCardHighlight(for: dawn, color: CardNode.getFontColor(for: .dawn))
            container.addChild(highlight)
        }
        
        if let night = nightCard {
            let highlight = createCardHighlight(for: night, color: CardNode.getFontColor(for: .night))
            container.addChild(highlight)
        }
        
        return container.children.isEmpty ? nil : container
    }
    
    private func createGlowRect(around rect: CGRect, color: SKColor) -> SKShapeNode {
        let padding: CGFloat = 10
        let glow = SKShapeNode(rectOf: CGSize(
            width: rect.width + padding * 2,
            height: rect.height + padding * 2
        ), cornerRadius: 8)
        
        glow.position = CGPoint(x: rect.midX, y: rect.midY)
        glow.fillColor = .clear
        glow.strokeColor = color
        glow.lineWidth = 3
        glow.alpha = 0.8
        
        // Pulsing animation
        glow.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.4, duration: 0.8),
            SKAction.fadeAlpha(to: 0.8, duration: 0.8)
        ])))
        
        return glow
    }
    
    private func clearStepUI() {
        messageNode?.removeFromParent()
        highlightNode?.removeFromParent()
        
        messageNode = nil
        highlightNode = nil
    }
    
    private func clearUI() {
        clearStepUI()
        overlay?.removeFromParent()
        overlay = nil
    }
    
    // MARK: - Content Methods
    
    private func getMessageForStep(_ step: TutorialStep) -> String {
        switch step {
        case .welcome:
            return "Welcome to Penumbral! This tutorial will guide you through the basics of the game."
            
        case .objective:
            return "The goal is to win 3 rounds. Each round is won by winning 3 hands. Track your progress in the score table."
            
        case .cardSuits:
            return "Your cards come in three suits: Dawn (white), Night (gray), and Dusk (purple). Each has unique abilities."
            
        case .dawnCards:
            return "Dawn cards (white) score immediate points equal to their value. They're great for gaining an immediate advantage."
            
        case .nightCards:
            return "Night cards (grey) bank power for later use instead of scoring. This stored power can be used in future rounds."
            
        case .duskCards:
            return "Dusk cards (purple) lock your opponent's banked power and can cancel it. They're excellent for control."
            
        case .gameFlow:
            return "In each hand, you and your opponent will play two cards in sequence: a first card, then a second card."
            
        case .firstCard:
            return "Select your first card now. Try a Dawn card to score immediate points."
            
        case .secondCard:
            return "Now select your second card. Tap on various cards to see how they will be scored!"
            
        case .combinations:
            return "Same-suit combinations are very powerful:\n• Dawn+Dawn: Double points\n• Night+Night: Double banking\n• Dusk+Dusk: Score AND cancel"
            
        case .crossSuitCombos:
                return "When mixing different suits, the second card's effect is doubled! For example, playing Night then Dawn gives double Dawn points, or Dawn then Night banks double power."
            
        case .banking:
            return "When you have power banked from Night cards, tap the 'Use Banked Power' button to add it to your score."
            
        case .winning:
            return "Win hands by having a higher score than your opponent. Win 3 hands to win a round, and 3 rounds to win the match!"
            
        case .tips:
            return "Tip: You don't have to win every hand, or even every round! Be strategic about when you want to make a push to win."
            
        case .tapHelp:
                return "If you need a reminder about card combinations, tap the Help button in the top-left corner."
            
        case .completion:
            return "Tutorial complete! You're ready to play Penumbral. Good luck!"
        }
    }
}
