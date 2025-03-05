//
//  NodeTypeScreens.swift
//  CardLoop
//
//  Created by Braxton Smallwood on 3/4/25.
//

import SpriteKit

// MARK: - Battle Node Screen

class BattleNodeScreen: NodeInteractionScreen {
    private let difficulty: Int
    private let enemyType: String
    
    override init(node: WorldNode, size: CGSize, parentScene: EnhancedCelestialRealmScene?) {
        // Extract battle-specific data
        guard case let .battle(difficulty, enemyType) = node.nodeType else {
            fatalError("Invalid node type for BattleNodeScreen")
        }
        self.difficulty = difficulty
        self.enemyType = enemyType
        
        super.init(node: node, size: size, parentScene: parentScene)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func getTitle() -> String {
        return "Battle: \(enemyType)"
    }
    
    override func setupSpecificContent() {
        // Difficulty indicator
        let difficultyText = String(repeating: "⭐️", count: difficulty)
        let difficultyLabel = createInfoText(
            text: "Difficulty: \(difficultyText)",
            fontSize: 20,
            position: CGPoint(x: 0, y: 60)
        )
        contentArea.addChild(difficultyLabel)
        
        // Enemy preview
        let enemyPreview = SKShapeNode(rectOf: CGSize(width: 120, height: 180), cornerRadius: 10)
        enemyPreview.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
        enemyPreview.strokeColor = .white
        enemyPreview.position = CGPoint(x: 0, y: -20)
        contentArea.addChild(enemyPreview)
        
        // Enemy icon
        let enemyIcon = SKShapeNode(circleOfRadius: 40)
        enemyIcon.fillColor = node.realm.color
        enemyIcon.strokeColor = .white
        enemyIcon.position = CGPoint(x: 0, y: 20)
        enemyPreview.addChild(enemyIcon)
        
        // Enemy type label
        let typeLabel = SKLabelNode(fontNamed: "Copperplate")
        typeLabel.text = enemyType
        typeLabel.fontSize = 16
        typeLabel.fontColor = .white
        typeLabel.position = CGPoint(x: 0, y: -40)
        enemyPreview.addChild(typeLabel)
        
        // Battle description
        let description = "Prepare to face a \(enemyType) in combat. This adversary will test your mastery of card combinations and timing."
        let descriptionText = createInfoText(
            text: description,
            maxWidth: screenWidth - 140,
            position: CGPoint(x: 0, y: -120)
        )
        contentArea.addChild(descriptionText)
        
        // Begin battle button
        let beginButton = createButton(
            text: "Begin Battle",
            size: CGSize(width: 160, height: 40),
            position: CGPoint(x: 0, y: -180)
        )
        beginButton.name = "beginBattleButton"
        contentArea.addChild(beginButton)
        
        // Add a subtle pulsing effect to the button
        beginButton.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])))
    }
    
    override func handleTouch(at location: CGPoint) -> Bool {
        if super.handleTouch(at: location) {
            return true
        }
        
        // Check for begin battle button touch
        if let beginButton = contentArea.childNode(withName: "beginBattleButton") {
            if beginButton.contains(convert(location, to: contentArea)) {
                // Transition to battle would happen here
                // For now, just dismiss and return to the exploration screen
                parentScene?.dismissExploration()
                return true
            }
        }
        
        return false
    }
}

// MARK: - Card Refinery Node Screen

class RefineryNodeScreen: NodeInteractionScreen {
    override func getTitle() -> String {
        return "Card Refinery"
    }
    
    override func setupSpecificContent() {
        // Refinery description
        let description = "Here you can upgrade and modify your cards to create more powerful combinations. Select a card from your deck to begin the refinement process."
        let descriptionText = createInfoText(
            text: description,
            maxWidth: screenWidth - 120,
            position: CGPoint(x: 0, y: 80)
        )
        contentArea.addChild(descriptionText)
        
        // Card selection area
        let cardSelectionArea = SKShapeNode(rectOf: CGSize(width: screenWidth - 140, height: 120), cornerRadius: 10)
        cardSelectionArea.fillColor = SKColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 0.7)
        cardSelectionArea.strokeColor = .white
        cardSelectionArea.lineWidth = 1
        cardSelectionArea.position = CGPoint(x: 0, y: 0)
        contentArea.addChild(cardSelectionArea)
        
        // Add placeholder card slots
        let slotWidth: CGFloat = 80
        let slotCount = 5
        let totalWidth = slotWidth * CGFloat(slotCount)
        let startX = -totalWidth/2 + slotWidth/2
        
        for i in 0..<slotCount {
            let cardSlot = SKShapeNode(rectOf: CGSize(width: slotWidth - 10, height: 100), cornerRadius: 8)
            cardSlot.fillColor = SKColor.darkGray.withAlphaComponent(0.3)
            cardSlot.strokeColor = .lightGray
            cardSlot.lineWidth = 1
            cardSlot.position = CGPoint(x: startX + CGFloat(i) * slotWidth, y: 0)
            cardSlot.name = "cardSlot_\(i)"
            cardSelectionArea.addChild(cardSlot)
            
            // Add + symbol to indicate it's selectable
            let plusSymbol = SKLabelNode(fontNamed: "Helvetica")
            plusSymbol.text = "+"
            plusSymbol.fontSize = 30
            plusSymbol.fontColor = .lightGray
            plusSymbol.verticalAlignmentMode = .center
            plusSymbol.position = cardSlot.position
            cardSelectionArea.addChild(plusSymbol)
        }
        
        // Refinement options (disabled for now)
        let optionsText = createInfoText(
            text: "Refinement Options (Select a card first)",
            fontSize: 16,
            position: CGPoint(x: 0, y: -80)
        )
        contentArea.addChild(optionsText)
        
        // Options buttons (disabled)
        let options = ["Enhance Power", "Change Suit", "Add Effect"]
        let buttonWidth: CGFloat = 140
        let buttonSpacing: CGFloat = 20
        let totalButtonWidth = buttonWidth * CGFloat(options.count) + buttonSpacing * CGFloat(options.count - 1)
        let buttonStartX = -totalButtonWidth/2 + buttonWidth/2
        
        for (i, option) in options.enumerated() {
            let button = createButton(
                text: option,
                size: CGSize(width: buttonWidth, height: 36),
                position: CGPoint(x: buttonStartX + CGFloat(i) * (buttonWidth + buttonSpacing), y: -120)
            )
            button.alpha = 0.5 // Disabled appearance
            contentArea.addChild(button)
        }
        
        // Help text
        let helpText = createInfoText(
            text: "Note: This is a placeholder interface. In the full game, you would be able to select cards and refine them with various options.",
            fontSize: 14,
            maxWidth: screenWidth - 140,
            position: CGPoint(x: 0, y: -170)
        )
        helpText.alpha = 0.7
        contentArea.addChild(helpText)
    }
    
    override func handleTouch(at location: CGPoint) -> Bool {
        if super.handleTouch(at: location) {
            return true
        }
        
        // Check for card slot touches
        for i in 0..<5 {
            if let cardSlot = contentArea.childNode(withName: "//cardSlot_\(i)") {
                if cardSlot.contains(convert(location, to: cardSlot.parent!)) {
                    // Flash the card slot to indicate selection
                    let flash = SKAction.sequence([
                        SKAction.colorize(with: .white, colorBlendFactor: 0.5, duration: 0.1),
                        SKAction.colorize(withColorBlendFactor: 0, duration: 0.1)
                    ])
                    cardSlot.run(flash)
                    return true
                }
            }
        }
        
        return false
    }
}

// MARK: - Narrative Node Screen

class NarrativeNodeScreen: NodeInteractionScreen {
    private let character: String
    private let dialogueID: String
    private var currentDialogueIndex = 0
    private var dialogueTexts: [String] = []
    
    override init(node: WorldNode, size: CGSize, parentScene: EnhancedCelestialRealmScene?) {
        // Extract narrative-specific data
        guard case let .narrative(dialogueID, character) = node.nodeType else {
            fatalError("Invalid node type for NarrativeNodeScreen")
        }
        self.character = character
        self.dialogueID = dialogueID
        
        super.init(node: node, size: size, parentScene: parentScene)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func getTitle() -> String {
        return character
    }
    
    override func setupSpecificContent() {
        // Character portrait
        let portraitFrame = SKShapeNode(circleOfRadius: 50)
        portraitFrame.fillColor = node.realm.color.withAlphaComponent(0.7)
        portraitFrame.strokeColor = .white
        portraitFrame.lineWidth = 2
        portraitFrame.position = CGPoint(x: -120, y: 50)
        contentArea.addChild(portraitFrame)
        
        // Character icon/silhouette
        let characterIcon = SKShapeNode(rectOf: CGSize(width: 40, height: 70))
        characterIcon.fillColor = .white
        characterIcon.strokeColor = .clear
        characterIcon.alpha = 0.5
        characterIcon.position = CGPoint(x: 0, y: -5)
        portraitFrame.addChild(characterIcon)
        
        // Character name
        let nameLabel = SKLabelNode(fontNamed: "Copperplate")
        nameLabel.text = character
        nameLabel.fontSize = 16
        nameLabel.fontColor = .white
        nameLabel.verticalAlignmentMode = .center
        nameLabel.position = CGPoint(x: -120, y: -20)
        contentArea.addChild(nameLabel)
        
        // Dialogue box
        let dialogueBox = SKShapeNode(rectOf: CGSize(width: screenWidth - 200, height: 150), cornerRadius: 10)
        dialogueBox.fillColor = SKColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 0.7)
        dialogueBox.strokeColor = .white
        dialogueBox.lineWidth = 1
        dialogueBox.position = CGPoint(x: 30, y: 0)
        contentArea.addChild(dialogueBox)
        
        // Set up dialogue texts based on character and realm
        setupDialogueTexts()
        
        // Initial dialogue text
        let dialogueText = SKLabelNode(fontNamed: "Copperplate")
        dialogueText.text = dialogueTexts[currentDialogueIndex]
        dialogueText.fontSize = 16
        dialogueText.fontColor = .white
        dialogueText.verticalAlignmentMode = .center
        dialogueText.horizontalAlignmentMode = .center
        dialogueText.preferredMaxLayoutWidth = screenWidth - 220
        dialogueText.numberOfLines = 0
        dialogueText.position = CGPoint(x: 30, y: 0)
        dialogueText.name = "dialogueText"
        contentArea.addChild(dialogueText)
        
        // Continue button
        let continueButton = createButton(
            text: "Continue",
            size: CGSize(width: 120, height: 36),
            position: CGPoint(x: 120, y: -100)
        )
        continueButton.name = "continueButton"
        contentArea.addChild(continueButton)
        
        // Dialog progress indicator
        updateDialogueIndicator()
    }
    
    private func setupDialogueTexts() {
        // In a real implementation, these would come from a dialogue database
        // For the prototype, generate placeholder dialogue based on character and realm
        
        switch node.realm {
        case .dawn:
            dialogueTexts = [
                "Greetings, traveler. I am \(character), guardian of the Dawn realm. The balance between the realms grows ever more precarious.",
                "The Dawn cards represent immediate power - a direct approach that can overwhelm enemies before they have time to prepare.",
                "However, one who relies solely on Dawn loses the strategic advantages offered by the other realms. True mastery comes from understanding when to use each.",
                "I sense great potential in you. Continue your journey through the celestial realms, and you may discover the secrets that bind them together."
            ]
            
        case .dusk:
            dialogueTexts = [
                "So, you've found your way to me. I am \(character), watcher of the twilight between realms. Few venture this far from the sanctuary of Dawn.",
                "Dusk cards are about control and denial. They prevent your opponents from executing their strategies while setting up your own victory.",
                "The most devastating combinations often begin with carefully played Dusk cards, locking your opponent's options before they realize the trap.",
                "The path ahead grows darker still. Proceed with caution, for the Night realm tests both skill and resolve. Not all who enter return unchanged."
            ]
            
        case .night:
            dialogueTexts = [
                "You stand at the edge of darkness. I am \(character), keeper of the deepest mysteries. Few have the courage to seek me out.",
                "Night cards are about patient power - banking strength for critical moments. Those who master timing will find themselves unstoppable.",
                "The greatest victories come not from brute force, but from the careful accumulation of power, released at the perfect moment to shatter an opponent's defense.",
                "You have learned much on your journey through the realms. Take this knowledge back to the Dawn, and prepare for the greater challenges that await."
            ]
        }
    }
    
    private func updateDialogueIndicator() {
        // Remove any existing indicators
        contentArea.children.filter { $0.name?.hasPrefix("dialogueIndicator") == true }.forEach { $0.removeFromParent() }
        
        // Create new indicator dots
        let dotRadius: CGFloat = 4
        let dotSpacing: CGFloat = 12
        let totalWidth = dotSpacing * CGFloat(dialogueTexts.count - 1)
        let startX = -totalWidth/2
        
        for i in 0..<dialogueTexts.count {
            let dot = SKShapeNode(circleOfRadius: dotRadius)
            dot.fillColor = i == currentDialogueIndex ? .white : .gray
            dot.strokeColor = .clear
            dot.position = CGPoint(x: startX + CGFloat(i) * dotSpacing, y: -130)
            dot.name = "dialogueIndicator_\(i)"
            contentArea.addChild(dot)
        }
    }
    
    override func handleTouch(at location: CGPoint) -> Bool {
        if super.handleTouch(at: location) {
            return true
        }
        
        // Check for continue button touch
        if let continueButton = contentArea.childNode(withName: "continueButton") {
            if continueButton.contains(convert(location, to: contentArea)) {
                advanceDialogue()
                return true
            }
        }
        
        // Also advance dialogue if tapping on dialogue text
        if let dialogueText = contentArea.childNode(withName: "dialogueText") {
            if dialogueText.contains(convert(location, to: contentArea)) {
                advanceDialogue()
                return true
            }
        }
        
        return false
    }
    
    private func advanceDialogue() {
        // Move to next dialogue or end if at last one
        if currentDialogueIndex < dialogueTexts.count - 1 {
            currentDialogueIndex += 1
            
            // Update dialogue text
            if let dialogueText = contentArea.childNode(withName: "dialogueText") as? SKLabelNode {
                // Fade out current text
                dialogueText.run(SKAction.sequence([
                    SKAction.fadeOut(withDuration: 0.2),
                    SKAction.run { [weak self] in
                        guard let self = self else { return }
                        dialogueText.text = self.dialogueTexts[self.currentDialogueIndex]
                    },
                    SKAction.fadeIn(withDuration: 0.2)
                ]))
                
                // Update indicator
                updateDialogueIndicator()
                
                // Change continue button text if at last dialogue
                if currentDialogueIndex == dialogueTexts.count - 1 {
                    if let continueButton = contentArea.childNode(withName: "continueButton") {
                        if let buttonLabel = continueButton.children.first(where: { $0 is SKLabelNode }) as? SKLabelNode {
                            buttonLabel.text = "Complete"
                        }
                    }
                }
            }
        } else {
            // At the end of dialogue, dismiss
            dismiss()
        }
    }
}

// MARK: - Shop Node Screen

class ShopNodeScreen: NodeInteractionScreen {
    override func getTitle() -> String {
        return "Merchant Shop"
    }
    
    override func setupSpecificContent() {
        // Merchant greeting
        let greeting = createInfoText(
            text: "\"Welcome, traveler! I have rare treasures from across the realms. What catches your eye?\"",
            fontSize: 16,
            maxWidth: screenWidth - 120,
            position: CGPoint(x: 0, y: 80)
        )
        contentArea.addChild(greeting)
        
        // Shop inventory
        let shopItems = [
            (name: "Dawn Strategem", type: "Card", cost: 120),
            (name: "Dusk Veil", type: "Card", cost: 150),
            (name: "Night Essence", type: "Resource", cost: 80),
            (name: "Realm Map", type: "Item", cost: 200)
        ]
        
        // Create a shop inventory grid
        let itemWidth: CGFloat = 120
        let itemHeight: CGFloat = 150
        let itemsPerRow = 3
        let rowSpacing: CGFloat = 20
        
        for (index, item) in shopItems.enumerated() {
            let row = index / itemsPerRow
            let col = index % itemsPerRow
            
            let x = CGFloat(col) * (itemWidth + 20) - itemWidth
            let y = -CGFloat(row) * (itemHeight + rowSpacing)
            
            let itemNode = createShopItem(name: item.name, type: item.type, cost: item.cost, position: CGPoint(x: x, y: y))
            itemNode.name = "shopItem_\(index)"
            contentArea.addChild(itemNode)
        }
        
        // Player currency display
        let currencyDisplay = SKShapeNode(rectOf: CGSize(width: 160, height: 40), cornerRadius: 10)
        currencyDisplay.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 0.8)
        currencyDisplay.strokeColor = .white
        currencyDisplay.lineWidth = 1
        currencyDisplay.position = CGPoint(x: -100, y: -180)
        contentArea.addChild(currencyDisplay)
        
        let currencyLabel = SKLabelNode(fontNamed: "Copperplate")
        currencyLabel.text = "Essence: 350"
        currencyLabel.fontSize = 16
        currencyLabel.fontColor = .white
        currencyLabel.verticalAlignmentMode = .center
        currencyLabel.position = currencyDisplay.position
        contentArea.addChild(currencyLabel)
    }
    
    private func createShopItem(name: String, type: String, cost: Int, position: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = position
        
        // Item background
        let background = SKShapeNode(rectOf: CGSize(width: 110, height: 140), cornerRadius: 8)
        background.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 0.8)
        background.strokeColor = .white
        background.lineWidth = 1
        container.addChild(background)
        
        // Item icon
        let iconBackground = SKShapeNode(rectOf: CGSize(width: 90, height: 90), cornerRadius: 5)
        let iconColor: SKColor
        switch type {
        case "Card": iconColor = Realm.dawn.color
        case "Resource": iconColor = Realm.night.color
        default: iconColor = Realm.dusk.color
        }
        iconBackground.fillColor = iconColor.withAlphaComponent(0.5)
        iconBackground.strokeColor = iconColor
        iconBackground.position = CGPoint(x: 0, y: 15)
        container.addChild(iconBackground)
        
        // Item name
        let nameLabel = SKLabelNode(fontNamed: "Copperplate")
        nameLabel.text = name
        nameLabel.fontSize = 14
        nameLabel.fontColor = .white
        nameLabel.verticalAlignmentMode = .center
        nameLabel.position = CGPoint(x: 0, y: -35)
        container.addChild(nameLabel)
        
        // Item cost
        let costLabel = SKLabelNode(fontNamed: "Copperplate")
        costLabel.text = "\(cost)"
        costLabel.fontSize = 14
        costLabel.fontColor = .yellow
        costLabel.verticalAlignmentMode = .center
        costLabel.position = CGPoint(x: 0, y: -60)
        container.addChild(costLabel)
        
        // Buy button
        let buyButton = SKShapeNode(rectOf: CGSize(width: 50, height: 24), cornerRadius: 5)
        buyButton.fillColor = SKColor(red: 0.2, green: 0.4, blue: 0.2, alpha: 0.8)
        buyButton.strokeColor = .white
        buyButton.lineWidth = 1
        buyButton.position = CGPoint(x: 0, y: -60)
        buyButton.name = "buyButton"
        container.addChild(buyButton)
        
        let buyLabel = SKLabelNode(fontNamed: "Copperplate")
        buyLabel.text = "Buy"
        buyLabel.fontSize = 12
        buyLabel.fontColor = .white
        buyLabel.verticalAlignmentMode = .center
        buyLabel.position = buyButton.position
        container.addChild(buyLabel)
        
        return container
    }
    
    override func handleTouch(at location: CGPoint) -> Bool {
        if super.handleTouch(at: location) {
            return true
        }
        
        // Check for shop item touches
        for i in 0..<4 {
            if let itemNode = contentArea.childNode(withName: "shopItem_\(i)") {
                if itemNode.contains(convert(location, to: contentArea)) {
                    // Check if buy button was touched
                    if let buyButton = itemNode.childNode(withName: "buyButton") {
                        if buyButton.contains(convert(location, to: itemNode)) {
                            // Flash the buy button to indicate purchase attempt
                            buyButton.run(SKAction.sequence([
                                SKAction.colorize(with: .green, colorBlendFactor: 0.5, duration: 0.1),
                                SKAction.colorize(withColorBlendFactor: 0, duration: 0.1)
                            ]))
                            
                            // Show purchase feedback
                            showPurchaseFeedback(atPosition: itemNode.position)
                            return true
                        }
                    }
                    
                    // Flash the item to indicate selection
                    let flash = SKAction.sequence([
                        SKAction.colorize(with: .white, colorBlendFactor: 0.3, duration: 0.1),
                        SKAction.colorize(withColorBlendFactor: 0, duration: 0.1)
                    ])
                    if let background = itemNode.children.first as? SKShapeNode {
                        background.run(flash)
                    }
                    return true
                }
            }
        }
        
        return false
    }
    
    private func showPurchaseFeedback(atPosition position: CGPoint) {
        // Create a feedback popup
        let feedback = SKLabelNode(fontNamed: "Copperplate")
        feedback.text = "Purchase successful!"
        feedback.fontSize = 16
        feedback.fontColor = .green
        feedback.position = CGPoint(x: position.x, y: position.y + 30)
        feedback.setScale(0)
        contentArea.addChild(feedback)
        
        // Animate the feedback
        feedback.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.0, duration: 0.2),
                SKAction.fadeIn(withDuration: 0.2)
            ]),
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }
}

// MARK: - Mystery Node Screen

class MysteryNodeScreen: NodeInteractionScreen {
    private var revealedEffect: String = ""
    private var isRevealed: Bool = false
    
    override func getTitle() -> String {
        return "Mystery Node"
    }
    
    override func setupSpecificContent() {
        // Mystery description
        let description = "You've encountered a mysterious energy pattern. Its purpose is unclear, but it seems to be reacting to your presence."
        let descriptionText = createInfoText(
            text: description,
            maxWidth: screenWidth - 120,
            position: CGPoint(x: 0, y: 80)
        )
        contentArea.addChild(descriptionText)
        
        // Mystery orb (visual representation)
        let orbContainer = SKNode()
        orbContainer.position = CGPoint(x: 0, y: 0)
        contentArea.addChild(orbContainer)
        
        let outerGlow = SKShapeNode(circleOfRadius: 60)
        outerGlow.fillColor = .clear
        outerGlow.strokeColor = node.realm.color
        outerGlow.lineWidth = 3
        outerGlow.alpha = 0.7
        outerGlow.name = "outerGlow"
        orbContainer.addChild(outerGlow)
        
        let innerGlow = SKShapeNode(circleOfRadius: 40)
        innerGlow.fillColor = node.realm.color.withAlphaComponent(0.3)
        innerGlow.strokeColor = .clear
        innerGlow.name = "innerGlow"
        orbContainer.addChild(innerGlow)
        
        let core = SKShapeNode(circleOfRadius: 20)
        core.fillColor = node.realm.color
        core.strokeColor = .white
        core.lineWidth = 1
        core.name = "core"
        orbContainer.addChild(core)
        
        // Pulsing animation
        outerGlow.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 1.5),
            SKAction.scale(to: 1.0, duration: 1.5)
        ])))
        
        innerGlow.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 2.0),
            SKAction.scale(to: 1.0, duration: 2.0)
        ])))
        
        // Interaction prompt
        let promptText = createInfoText(
            text: "Touch the orb to interact with it.",
            fontSize: 16,
            position: CGPoint(x: 0, y: -80)
        )
        promptText.name = "promptText"
        contentArea.addChild(promptText)
        
        // Add a subtle rotation to the entire mystery orb
        orbContainer.run(SKAction.repeatForever(
            SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 20)
        ))
    }
    
    override func handleTouch(at location: CGPoint) -> Bool {
        if super.handleTouch(at: location) {
            return true
        }
        
        // Check for orb touch
        if let core = contentArea.childNode(withName: "//core") {
            let orbPosition = convert(core.position, from: core.parent!)
            let distance = hypot(location.x - orbPosition.x, location.y - orbPosition.y)
            
            // Check if touch is within the orb
            if distance < 60 && !isRevealed {
                revealMysteryEffect()
                return true
            }
        }
        
        return false
    }
    
    private func revealMysteryEffect() {
        isRevealed = true
        
        // Define possible effects
        let effects = [
            "You found a cache of resources! +10 Essence.",
            "An ancient card reveals itself to you. Added to your collection.",
            "A strange energy fills you. Your next battle will start with 5 banked power.",
            "The mists part to reveal a hidden path. A new area is visible on your map.",
            "A vision of strategy flashes in your mind. You can now see one enemy card per battle."
        ]
        
        // Randomly select an effect
        revealedEffect = effects.randomElement() ?? effects[0]
        
        // Animate the revelation
        let orbContainer = contentArea.childNode(withName: "//outerGlow")?.parent
        let promptText = contentArea.childNode(withName: "promptText")
        
        // Stop current animations
        orbContainer?.removeAllActions()
        orbContainer?.children.forEach { $0.removeAllActions() }
        
        // Flash effect
        let flash = SKShapeNode(circleOfRadius: 100)
        flash.fillColor = .white
        flash.strokeColor = .clear
        flash.alpha = 0
        flash.position = orbContainer?.position ?? .zero
        contentArea.addChild(flash)
        
        flash.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: 0.2),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
        
        // Shrink orb and fade it out
        orbContainer?.run(SKAction.group([
            SKAction.scale(to: 0.5, duration: 0.5),
            SKAction.fadeOut(withDuration: 0.5)
        ]))
        
        // Remove prompt text
        promptText?.run(SKAction.fadeOut(withDuration: 0.3))
        
        // Show effect text
        let effectText = createInfoText(
            text: revealedEffect,
            fontSize: 18,
            maxWidth: screenWidth - 120,
            position: CGPoint(x: 0, y: 0)
        )
        effectText.alpha = 0
        contentArea.addChild(effectText)
        
        effectText.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeIn(withDuration: 0.3)
        ]))
        
        // Show claim button
        let claimButton = createButton(
            text: "Claim Reward",
            size: CGSize(width: 150, height: 40),
            position: CGPoint(x: 0, y: -100)
        )
        claimButton.name = "claimButton"
        claimButton.alpha = 0
        contentArea.addChild(claimButton)
        
        claimButton.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.8),
            SKAction.fadeIn(withDuration: 0.3)
        ]))
    }
}

// MARK: - Nexus Node Screen

class NexusNodeScreen: NodeInteractionScreen {
    override func getTitle() -> String {
        return "Nexus Hub"
    }
    
    override func setupSpecificContent() {
        // Nexus description
        let description = "You stand at the central Nexus, where all realms converge. From here, you can access any area of the Celestial Realm or prepare for your journey."
        let descriptionText = createInfoText(
            text: description,
            maxWidth: screenWidth - 120,
            position: CGPoint(x: 0, y: 80)
        )
        contentArea.addChild(descriptionText)
        
        // Realm indicators in a circle
        let realmIcons = SKNode()
        realmIcons.position = CGPoint(x: 0, y: 0)
        contentArea.addChild(realmIcons)
        
        let realms = Realm.allCases
        let radius: CGFloat = 80
        
        for (index, realm) in realms.enumerated() {
            let angle = 2 * CGFloat.pi * CGFloat(index) / CGFloat(realms.count)
            let x = radius * cos(angle)
            let y = radius * sin(angle)
            
            // Realm indicator
            let realmNode = SKShapeNode(circleOfRadius: 25)
            realmNode.fillColor = realm.color.withAlphaComponent(0.7)
            realmNode.strokeColor = .white
            realmNode.lineWidth = 2
            realmNode.position = CGPoint(x: x, y: y)
            realmNode.name = "realm_\(realm.rawValue)"
            realmIcons.addChild(realmNode)
            
            // Realm name
            let nameLabel = SKLabelNode(fontNamed: "Copperplate")
            nameLabel.text = realm.rawValue.capitalized
            nameLabel.fontSize = 14
            nameLabel.fontColor = .white
            nameLabel.position = CGPoint(x: x, y: y - 40)
            realmIcons.addChild(nameLabel)
            
            // Add glow to current realm
            if realm == celestialRealm!.currentPhase {
                let glow = SKShapeNode(circleOfRadius: 30)
                glow.fillColor = .clear
                glow.strokeColor = .white
                glow.lineWidth = 2
                glow.position = realmNode.position
                glow.alpha = 0.7
                realmIcons.addChild(glow)
                
                glow.run(SKAction.repeatForever(SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.3, duration: 0.8),
                    SKAction.fadeAlpha(to: 0.7, duration: 0.8)
                ])))
            }
        }
        
        // Nexus actions
        let actions = ["View Status", "Prepare Deck", "Return to Battle"]
        let buttonWidth: CGFloat = 150
        let buttonSpacing: CGFloat = 20
        let totalButtonWidth = buttonWidth * CGFloat(actions.count) + buttonSpacing * CGFloat(actions.count - 1)
        let buttonStartX = -totalButtonWidth/2 + buttonWidth/2
        
        for (i, action) in actions.enumerated() {
            let button = createButton(
                text: action,
                size: CGSize(width: buttonWidth, height: 40),
                position: CGPoint(x: buttonStartX + CGFloat(i) * (buttonWidth + buttonSpacing), y: -100)
            )
            button.name = "action_\(action.replacingOccurrences(of: " ", with: ""))"
            contentArea.addChild(button)
        }
    }
    
    override func handleTouch(at location: CGPoint) -> Bool {
        if super.handleTouch(at: location) {
            return true
        }
        
        // Check for realm selection
        for realm in Realm.allCases {
            if let realmNode = contentArea.childNode(withName: "//realm_\(realm.rawValue)") {
                if realmNode.contains(convert(location, to: realmNode.parent!)) {
                    // Highlight the selected realm
                    let flash = SKAction.sequence([
                        SKAction.scale(to: 1.2, duration: 0.1),
                        SKAction.scale(to: 1.0, duration: 0.1)
                    ])
                    realmNode.run(flash)
                    
                    // Change to this realm phase
                    while celestialRealm!.currentPhase != realm {
                        celestialRealm!.shiftPhase()
                    }
                    
                    // Update visualization
                    parentScene?.updateVisualization()
                    
                    return true
                }
            }
        }
        
        // Check for action buttons
        let actionNames = ["ViewStatus", "PrepareDeck", "ReturnToBattle"]
        
        for actionName in actionNames {
            if let actionButton = contentArea.childNode(withName: "action_\(actionName)") {
                if actionButton.contains(convert(location, to: contentArea)) {
                    // Flash the button to indicate selection
                    let flash = SKAction.sequence([
                        SKAction.scale(to: 1.1, duration: 0.1),
                        SKAction.scale(to: 1.0, duration: 0.1)
                    ])
                    actionButton.run(flash)
                    
                    // Handle specific actions
                    if actionName == "ReturnToBattle" {
                        parentScene?.dismissExploration()
                    } else {
                        // For other actions, just dismiss this screen for now
                        dismiss()
                    }
                    
                    return true
                }
            }
        }
        
        return false
    }
}
